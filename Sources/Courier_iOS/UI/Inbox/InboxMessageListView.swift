//
//  InboxMessageListView.swift
//  Courier_iOS
//
//  Created by Michael Miller on 9/23/24.
//

import UIKit

internal class InboxMessageListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Message Types
    
    enum MessageState {
        case read
        case unread
        case archived
    }
    
    private let supportedMessageStates: [MessageState]
    
    // MARK: Theme
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierInboxTheme = .defaultLight
    
    // MARK: Interaction
    
    public var didClickInboxMessageAtIndex: ((InboxMessage, Int) -> Void)? = nil
    public var didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil
    public var didScrollInbox: ((UIScrollView) -> Void)? = nil
    
    // MARK: Datasource
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    // MARK: UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourierInboxTableViewCell.self, forCellReuseIdentifier: CourierInboxTableViewCell.id)
        tableView.register(CourierInboxPaginationCell.self, forCellReuseIdentifier: CourierInboxPaginationCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var infoView: CourierInfoView = {
        let view = CourierInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onButtonClick = { [weak self] in
            self?.state = .loading
            self?.onRefresh()
        }
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: Authentication
    
    private var authListener: CourierAuthenticationListener? = nil
    
    // MARK: State
    
    private var state: State = .loading {
        didSet {
            // Update UI
            switch (state) {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = true
            case .error:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
                self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No messages found")
            case .content:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.infoView.isHidden = true
            case .empty:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
                self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No messages found")
            }
            
            // Scroll to top if needed
            if ("\(oldValue)" != "\(state)") {
                self.scrollToTop(animated: false)
            }
        }
    }
    
    // MARK: Init
    
    public init(
        supportedMessageStates: [MessageState],
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        
        self.supportedMessageStates = supportedMessageStates
        
        // Theme
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        // Init
        super.init(frame: .zero)
        
        // Callbacks
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        
        // Styles and more
        setup()
    }

    override init(frame: CGRect) {
        self.supportedMessageStates = []
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.supportedMessageStates = []
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Called when the auth state changes
        authListener = Courier.shared.addAuthenticationListener { [weak self] userId in
            if (userId != nil) {
                self?.traitCollectionDidChange(nil)
                self?.state = .loading
                self?.onRefresh()
            }
        }
        
        // Set state
        state = .loading

        // Add the views
        addTableView()
        addLoadingIndicator()
        addInfoView()
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Init the listener
        makeListener()
        
    }
    
    private func addTableView() {
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func addLoadingIndicator() {
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func addInfoView() {
        addSubview(infoView)
        
        NSLayoutConstraint.activate([
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (Theme.margin / 2)),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(Theme.margin / 2)),
        ])
    }
    
    private func makeListener() {
        Task {
            do {
                try await refreshBrand()
            } catch {
                Courier.shared.client?.log(error.localizedDescription)
            }
            
            self.inboxListener = Courier.shared.addInboxListener(
                onInitialLoad: { [weak self] in
                    self?.state = .loading
                },
                onError: { [weak self] error in
                    self?.state = .error(error)
                },
                onMessagesChanged: { [weak self] newMessages, unreadMessageCount, totalMessageCount, canPaginate in
                    
                    // Filter all message that should be shown
                    let messages = newMessages.filter { message in
                        guard let supportedStates = self?.supportedMessageStates else { return false }
                        return (message.isArchived && supportedStates.contains(.archived)) || // Archived
                               (message.isRead && supportedStates.contains(.read)) || // Read
                               (!message.isRead && supportedStates.contains(.unread)) // Unread
                    }
                    
                    self?.state = messages.isEmpty ? .empty : .content
                    self?.canPaginate = canPaginate
                    self?.reloadMessages(messages)
                    
                }
            )
        }
    }
    
    // MARK: Reloading
    
    private func refreshBrand() async throws {
        if let brandId = self.theme.brandId {
            let res = try await Courier.shared.client?.brands.getBrand(brandId: brandId)
            self.theme.brand = res?.data.brand
            self.reloadViews()
        }
    }
    
    /**
     Adds the new message at top if needed
     Otherwise will reload all the messages with the new datasource
     */
    private func reloadMessages(_ newMessages: [InboxMessage]) {
        // Check if we need to insert
        let didInsert = newMessages.count - self.inboxMessages.count == 1
        if (newMessages.first?.messageId != self.inboxMessages.first?.messageId && didInsert) {
            // Add the new item
            self.inboxMessages = newMessages
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: theme.messageAnimationStyle)
            
            // Open shown messages
            self.openVisibleMessages()
            
            return
        }
        
        // Set the messages
        self.inboxMessages = newMessages
        self.tableView.reloadData()
        
        // Open shown messages
        self.openVisibleMessages()
    }
    
    @objc private func onRefresh() {
        Task {
            do {
                try await refreshBrand()
                await Courier.shared.refreshInbox()
                self.tableView.refreshControl?.endRefreshing()
            } catch {
                Courier.shared.client?.log(error.localizedDescription)
                self.state = .error(error)
            }
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.canPaginate ? 2 : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.inboxMessages.count : 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            // Normal cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxTableViewCell.id, for: indexPath) as? CourierInboxTableViewCell {
                let index = indexPath.row
                let message = inboxMessages[index]
                
                cell.setMessage(message, theme) { [weak self] inboxAction in
                    self?.didClickInboxActionForMessageAtIndex?(
                        inboxAction,
                        message,
                        index
                    )
                }
                
                return cell
            }
        } else {
            // Pagination cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxPaginationCell.id, for: indexPath) as? CourierInboxPaginationCell {
                cell.setTheme(theme)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexToPageAt = self.inboxMessages.count - Int(InboxModule.Pagination.default.rawValue / 3)
        
        // Only fetch if we are safe to
        if (indexPath.row == indexToPageAt) {
            Task {
                do {
                    try await Courier.shared.fetchNextInboxPage()
                } catch {
                    Courier.shared.client?.error(error.localizedDescription)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            // Click the cell
            let index = indexPath.row
            let message = self.inboxMessages[index]
            
            // Track the click
            message.markAsClicked()
            
            // Hit callback
            self.didClickInboxMessageAtIndex?(message, index)
            
            // Deselect the row
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func archiveCell(at index: Int) {
        
        let originalMessage = inboxMessages[index].copy()
        
        // Update the new message
        let newMessage = originalMessage.copy()
        newMessage.setArchived()
        
        // Get the cell
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? CourierInboxTableViewCell
        
        // Remove the message
        self.inboxMessages.remove(at: index)
        self.tableView.deleteRows(at: [indexPath], with: .left)
        
        // Ensure we have a listener
        guard let listener = self.inboxListener else {
            return
        }
        
        Task {
            do {
                
                // Update the datastore
                try await Courier.shared.inboxModule.updateMessage(
                    messageId: originalMessage.messageId,
                    event: .archive,
                    ignoredListeners: [listener]
                )
                
            } catch {
                
                Courier.shared.client?.log(error.localizedDescription)
                
                // Add the original message back
                self.inboxMessages.insert(originalMessage, at: index)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                
            }
        }
        
    }
    
    private func readCell(isRead: Bool, at index: Int) {
        
        // Instantly read the cell
        let message = inboxMessages[index]
        
        // Update the new message
        let newMessage = message.copy()
        isRead ? newMessage.setUnread() : newMessage.setRead()
        
        // Get the cell
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? CourierInboxTableViewCell
        
        // Reload with the new message copy
        cell?.refreshMessage(newMessage)
        
        // Ensure we have a listener
        guard let listener = self.inboxListener else {
            return
        }
        
        Task {
            do {
                
                // Update the datastore
                try await Courier.shared.inboxModule.updateMessage(
                    messageId: message.messageId,
                    event: isRead ? .unread : .read,
                    ignoredListeners: [listener]
                )
                
            } catch {
                
                Courier.shared.client?.log(error.localizedDescription)
                isRead ? message.setRead() : message.setUnread()
                cell?.refreshMessage(message)
                
            }
        }
        
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Check the read status of the message at the current indexPath
        let message = inboxMessages[indexPath.row]
        
        // Define the action dynamically based on whether the message is read or unread
        let actionTitle = message.isRead ? "Unread" : "Read"
        let actionIcon = message.isRead ? "envelope.fill" : "envelope.open.fill" // Closed envelope for unread, open for read
        let actionColor = message.isRead ? UIColor.systemGray : UIColor.systemBlue // Orange for unread, blue for read

        let toggleReadAction = UIContextualAction(style: .normal, title: actionTitle) { [weak self] (action, view, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.readCell(isRead: message.isRead, at: indexPath.row)
            completionHandler(true)
        }
        
        // Customize the appearance of the action
        toggleReadAction.backgroundColor = actionColor
        
        // Set the icon image dynamically
        if let icon = UIImage(systemName: actionIcon) {
            toggleReadAction.image = icon
        }
        
        // Create a configuration object with the action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [toggleReadAction])
        
        // Disable full swipe (so the action doesn't fully delete the cell)
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        
        return swipeConfiguration
        
    }
    
    // This method enables swipe actions for table view cells
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let archiveAction = UIContextualAction(style: .normal, title: "Archive") { [weak self] (action, view, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.archiveCell(at: indexPath.row)
            completionHandler(true)
        }
        
        // Customize the action appearance
        archiveAction.backgroundColor = .systemRed  // A neutral color for archive
        archiveAction.image = UIImage(systemName: "archivebox.fill") // Use SF Symbol for archive box
        
        // Create a configuration object with the action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [archiveAction])
        
        // Enable full swipe to perform the archive action
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        
        return swipeConfiguration
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollInbox?(scrollView)
        self.openVisibleMessages()
    }
    
    private func openVisibleMessages() {
        
        if !Courier.shared.isUserSignedIn {
            return
        }
            
        self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
            Task {
                
                // Get the current message
                let index = indexPath.row
                
                // Check if the index is within bounds
                guard index >= 0 && index < inboxMessages.count else {
                    return
                }
                
                let message = inboxMessages[index]

                // If the message is not opened, open it
                if (!message.isOpened) {
                    message.markAsOpened()
                }
                
            }
        }
        
    }
    
    public func scrollToTop(animated: Bool) {
        if (self.inboxMessages.isEmpty) {
            return
        }
        
        self.tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handles setting the theme of the Inbox
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
        }
    }
    
    private func setTheme(isDarkMode: Bool) {
        theme = isDarkMode ? darkTheme : lightTheme
        reloadViews()
    }
    
    private func reloadViews() {
        tableView.separatorStyle = theme.cellStyle.separatorStyle
        tableView.separatorInset = theme.cellStyle.separatorInsets
        tableView.separatorColor = theme.cellStyle.separatorColor
        
        tableView.refreshControl?.tintColor = theme.loadingColor
        loadingIndicator.color = theme.loadingColor
        
        infoView.setTheme(theme)
        
        reloadCells()
    }
    
    private func reloadCells() {
        if let paths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: paths, with: .none)
        }
    }
    
    /**
     Clear the listeners
     */
    deinit {
        self.authListener?.remove()
        self.inboxListener?.remove()
    }
}
