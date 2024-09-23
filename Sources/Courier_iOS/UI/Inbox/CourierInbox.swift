//
//  CourierInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit

/**
 A super simple way to implement a basic notification center into your app
 */
@available(iOSApplicationExtension, unavailable)
open class CourierInbox: UIView, UITableViewDelegate, UITableViewDataSource {
    
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
    
    private lazy var contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .blue
        return container
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .red
        return scrollView
    }()
    
    private lazy var courierBar: CourierBar = {
        let bar = CourierBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
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
    
    // MARK: Constraints
    
//    private var infoViewY: NSLayoutConstraint? = nil
    private var contentViewBottom: NSLayoutConstraint? = nil
    
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
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
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
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
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
        addCourierBar()
        
        addContent(
            content: scrollView,
            loading: loadingIndicator,
            info: infoView
        )
        
//        addLoadingIndicator()
//        addInfoView()
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Init the listener
        makeListener()
        
    }
    
    private func updateViewForCourierBar() {
        
        if (!courierBar.isHidden) {
            
            // Set the courier bar background color
            courierBar.setColors(with: superview?.backgroundColor)
            
            // Update infoView position
//            infoViewY?.constant = -(Theme.Bar.barHeight / 2)
//            infoView.layoutIfNeeded()
            
            contentViewBottom?.constant = -Theme.Bar.barHeight
            contentView.layoutIfNeeded()
            
        } else {
            
//            infoViewY?.constant = 0
//            infoView.layoutIfNeeded()
            
            contentViewBottom?.constant = 0
            contentView.layoutIfNeeded()
            
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateViewForCourierBar()
    }
    
    private func addContent(content: UIView, loading: UIView, info: UIView) {
        
        // Add the container
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        contentViewBottom = contentView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -Theme.Bar.barHeight
        )
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentViewBottom!
        ])
        
        contentView.layoutIfNeeded()
        
        // Content
        content.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: contentView.topAnchor),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        contentView.layoutIfNeeded()
        
        // Info
        info.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(info)
        
        NSLayoutConstraint.activate([
            info.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            info.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: (Theme.margin / 2)),
            info.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(Theme.margin / 2)),
        ])
        
        contentView.layoutIfNeeded()
        
        // Loading
        loading.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loading)
        
        NSLayoutConstraint.activate([
            loading.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layoutIfNeeded()
        
    }
    
    private func addCourierBar() {
        addSubview(courierBar)
        NSLayoutConstraint.activate([
            courierBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
//    private func addScrollView() {
//        addSubview(scrollView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
//        ])
//    }
    
//    private func addTableView() {
//        addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
//        ])
//    }
    
//    private func addLoadingIndicator() {
//        addSubview(loadingIndicator)
//        
//        NSLayoutConstraint.activate([
//            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
//        ])
//    }
//    
//    private func addInfoView() {
//        addSubview(infoView)
//        
//        infoViewY = infoView.centerYAnchor.constraint(equalTo: centerYAnchor)
//        
//        NSLayoutConstraint.activate([
//            infoViewY!,
//            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (Theme.margin / 2)),
//            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(Theme.margin / 2)),
//        ])
//    }
    
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
                    self?.state = newMessages.isEmpty ? .empty : .content
                    self?.canPaginate = canPaginate
                    self?.reloadMessages(newMessages)
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
                let message = inboxMessages[index]

                // If the message is not opened, open it
                if (!message.isOpened) {
                    // Mark the message as open
                    // This will prevent duplicates
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
        courierBar.setTheme(theme)
        
        reloadCells()
        updateViewForCourierBar()
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
