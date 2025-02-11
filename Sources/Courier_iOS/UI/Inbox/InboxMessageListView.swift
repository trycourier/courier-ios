//
//  InboxMessageListView.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 9/23/24.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class InboxMessageListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let feed: InboxMessageFeed
    
    // MARK: Theme

    private var theme: CourierInboxTheme = .defaultLight
    
    // MARK: Interaction
    
    private let didClickInboxMessageAtIndex: (InboxMessage, Int) -> Void
    private let didLongPressInboxMessageAtIndex: (InboxMessage, Int) -> Void
    private let didClickInboxActionForMessageAtIndex: (InboxAction, InboxMessage, Int) -> Void
    private let didScrollInbox: (UIScrollView) -> Void
    
    // MARK: Datasource
    
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    var canSwipePages = false
    
    // MARK: Parent
    
    internal var rootInbox: CourierInbox? = nil
    
    // MARK: UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
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
    
    private var isEmptyState: Bool {
        get {
            switch (state) {
            case .empty: return true
            default: return false
            }
        }
    }
    
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
                self.tableView.isHidden = false
                self.infoView.isHidden = false
                self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No messages found")
            }
        }
    }
    
    // MARK: Init
    
    public init(
        feed: InboxMessageFeed,
        didClickInboxMessageAtIndex: @escaping (_ message: InboxMessage, _ index: Int) -> Void,
        didLongPressInboxMessageAtIndex: @escaping (_ message: InboxMessage, _ index: Int) -> Void,
        didClickInboxActionForMessageAtIndex: @escaping (_ action: InboxAction, _ message: InboxMessage, _ index: Int) -> Void,
        didScrollInbox: @escaping (UIScrollView) -> Void
    ) {
        self.feed = feed
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didLongPressInboxMessageAtIndex = didLongPressInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        self.feed = .feed
        self.didClickInboxMessageAtIndex = { _, _ in }
        self.didLongPressInboxMessageAtIndex = { _, _ in }
        self.didClickInboxActionForMessageAtIndex = { _, _, _ in }
        self.didScrollInbox = { _ in }
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.feed = .feed
        self.didClickInboxMessageAtIndex = { _, _ in }
        self.didLongPressInboxMessageAtIndex = { _, _ in }
        self.didClickInboxActionForMessageAtIndex = { _, _, _ in }
        self.didScrollInbox = { _ in }
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        Task {
            authListener = await Courier.shared.addAuthenticationListener { [weak self] userId in
                if (userId != nil) {
                    self?.traitCollectionDidChange(nil)
                    self?.state = .loading
                    self?.onRefresh()
                }
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
        
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        self.theme = theme
        reloadViews()
    }
    
    internal func setLoading() {
        self.state = .loading
    }
    
    internal func setError(_ error: Error) {
        self.state = .error(error)
    }
    
    internal func setInbox(set: InboxMessageSet) async {
        self.manuallyArchivedMessageId = nil
        self.inboxMessages = set.messages
        self.canPaginate = set.canPaginate
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        self.state = inboxMessages.isEmpty ? .empty : .content
        await self.openVisibleMessages()
    }
    
    internal func addPage(set: InboxMessageSet) async {
        
        self.manuallyArchivedMessageId = nil
        
        if set.messages.isEmpty {
            self.canPaginate = false
            self.tableView.reloadData()
            return
        }
        
        let insertionIndex = inboxMessages.count
        self.inboxMessages.insert(contentsOf: set.messages, at: insertionIndex)
        self.state = inboxMessages.isEmpty ? .empty : .content
        
        let indexPaths = (insertionIndex..<insertionIndex + set.messages.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        // Add items to the table
        self.tableView.insertRows(at: indexPaths, with: .automatic)
        
        // Remove the reload cell
        let couldPaginate = self.canPaginate
        self.canPaginate = set.canPaginate
        if couldPaginate && !set.canPaginate {
            tableView.deleteSections(IndexSet(integer: 1), with: .automatic)
        }
        
        await self.openVisibleMessages()
        
    }
    
    internal func addMessage(at index: Int, message: InboxMessage) async {
        
        // Ensure the index is within bounds for insertion
        guard index >= 0 && index <= inboxMessages.count else {
            print("Error: Index \(index) is out of bounds for inboxMessages.")
            return
        }

        self.manuallyArchivedMessageId = nil
        self.inboxMessages.insert(message, at: index) // Safe insertion

        // Update the state based on inboxMessages' contents
        self.state = inboxMessages.isEmpty ? .empty : .content

        // Ensure the indexPath is valid for the tableView
        guard index >= 0 && index <= tableView.numberOfRows(inSection: 0) else {
            await Courier.shared.client?.log("Error: CourierInboxListView index \(index) is out of bounds.")
            self.tableView.reloadData()
            self.state = self.inboxMessages.isEmpty ? .empty : .content
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: theme.messageAnimationStyle) // Safe table view update
        await self.openVisibleMessages() // Additional logic
        
    }
    
    internal func updateMessage(at index: Int, message: InboxMessage) {
        
        if !canUpdateMessages(index: index, messageId: message.messageId) {
            return
        }
        
        self.inboxMessages[index] = message
        self.state = inboxMessages.isEmpty ? .empty : .content

        // Refresh the cell
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? CourierInboxTableViewCell
        cell?.refreshMessage(message)
        
    }
    
    internal func removeMessage(at index: Int, message: InboxMessage) async {
        
        // Check if index is within bounds and if the message matches
        guard index >= 0 && index < inboxMessages.count, inboxMessages[index].messageId == message.messageId else {
            print("Invalid index or message ID mismatch. Cannot remove message.")
            return
        }
        
        // Proceed if canUpdateMessages allows it
        if !canUpdateMessages(index: index, messageId: message.messageId) {
            return
        }

        // Remove the message from the data source first
        inboxMessages.remove(at: index)
        
        // React Native Bug fix... weird.
        if (await Courier.agent.isReactNative()) {
            self.tableView.reloadData()
            self.state = self.inboxMessages.isEmpty ? .empty : .content
            return
        }
        
        // Then, update the UI with the deletion
        let indexPath = IndexPath(row: index, section: 0)
        tableView.performBatchUpdates({
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }, completion: { finished in
            if finished {
                self.state = self.inboxMessages.isEmpty ? .empty : .content
            }
        })
        
    }
    
    private func canUpdateMessages(index: Int, messageId: String) -> Bool {
        
        if manuallyArchivedMessageId == messageId {
            return false
        }
        
        if inboxMessages.isEmpty {
            return false
        }
        
        if index > inboxMessages.count - 1 {
            return false
        }
        
        if inboxMessages[index].messageId != messageId {
            return false
        }
        
        return true
        
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
    
    @objc private func onRefresh() {
        Task {
            await rootInbox?.refreshBrand()
            await Courier.shared.refreshInbox()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.canPaginate ? 2 : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEmptyState ? 0 : section == 0 ? self.inboxMessages.count : 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxTableViewCell.id, for: indexPath) as? CourierInboxTableViewCell {
                
                let index = indexPath.row
                let message = inboxMessages[index]
                
                cell.setMessage(message, theme,
                    onActionClick: { [weak self] inboxAction in
                        self?.didClickInboxActionForMessageAtIndex(
                            inboxAction,
                            message,
                            index
                        )
                    },
                    onLongPress: { [weak self] inboxMessage in
                        Task {
                            await self?.handleLongPress(for: inboxMessage)
                        }
                    }
                )
                
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
    
    private func handleLongPress(for message: InboxMessage) async {
        let messages = self.feed == .feed ? await Courier.shared.feedMessages : await Courier.shared.archivedMessages
        if let index = messages.firstIndex(where: { $0.messageId == message.messageId }) {
            vibrate()
            self.didLongPressInboxMessageAtIndex(message, index)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && self.canPaginate) {
            Task {
                do {
                    try await Courier.shared.fetchNextInboxPage(self.feed)
                } catch {
                    await Courier.shared.client?.error(error.localizedDescription)
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
            self.didClickInboxMessageAtIndex(message, index)
            
            // Deselect the row
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
    }
    
    private var manuallyArchivedMessageId: String? = nil
    
    private func archiveCell(at index: Int) {
        
        let message = inboxMessages[index]
        
        Task {
            
            await removeMessage(at: index, message: message)
            
            // Hold the message id
            self.manuallyArchivedMessageId = message.messageId
            
            do {
                try await Courier.shared.archiveMessage(message.messageId)
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
            
        }
        
    }
    
    private func readCell(isRead: Bool, at index: Int) {

        let message = inboxMessages[index]
        
        Task {
            do {
                if isRead {
                    try await Courier.shared.unreadMessage(message.messageId)
                } else {
                    try await Courier.shared.readMessage(message.messageId)
                }
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
        }
        
    }
    
    // Reading handler
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let message = inboxMessages[indexPath.row]
        
        if (self.canSwipePages || message.isArchived) {
            return nil
        }
        
        let style = message.isRead ? self.theme.readingSwipeActionStyle.read : self.theme.readingSwipeActionStyle.unread
        let actionTitle = message.isRead ? "Unread" : "Read"

        let toggleReadAction = UIContextualAction(style: .normal, title: actionTitle) { [weak self] (action, view, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.readCell(isRead: message.isRead, at: indexPath.row)
            completionHandler(true)
        }
        
        // Customize the appearance of the action
        toggleReadAction.backgroundColor = style.color
        toggleReadAction.image = style.icon
        
        // Create a configuration object with the action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [toggleReadAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        
        return swipeConfiguration
        
    }
    
    // Archiving handler
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let message = inboxMessages[indexPath.row]
        
        if (self.canSwipePages || message.isArchived) {
            return nil
        }
        
        let archiveAction = UIContextualAction(style: .destructive, title: "Archive") { [weak self] (action, view, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.archiveCell(at: indexPath.row)
            completionHandler(true)
        }
        
        // Customize the action appearance
        let style = self.theme.archivingSwipeActionStyle.archive
        archiveAction.backgroundColor = style.color
        archiveAction.image = style.icon
        
        // Create a configuration object with the action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [archiveAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        
        return swipeConfiguration
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Task { [weak self] in
            self?.didScrollInbox(scrollView)
            await self?.openVisibleMessages()
        }
    }
    
    private func openVisibleMessages() async {
        
        if await !Courier.shared.isUserSignedIn {
            return
        }
            
        self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
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
    
    public func scrollToTop(animated: Bool) {
        
        if (self.inboxMessages.isEmpty) {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)

        guard indexPath.row < self.inboxMessages.count else {
            return
        }
        
        self.tableView.scrollToRow(
            at: indexPath,
            at: .top,
            animated: animated
        )
        
    }
    
    private func reloadViews() {
        tableView.separatorStyle = theme.cellStyle.separatorStyle
        tableView.separatorInset = theme.cellStyle.separatorInsets
        tableView.separatorColor = theme.cellStyle.separatorColor
        tableView.refreshControl?.tintColor = theme.loadingColor
        loadingIndicator.color = theme.loadingColor
        infoView.setTheme(theme)
        self.tableView.reloadData()
    }
    
    /**
     Clear the listeners
     */
    deinit {
        Task { [self] in
            await self.authListener?.remove()
        }
    }
    
}
