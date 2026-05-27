//
//  InboxMessageListView.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 9/23/24.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
internal class InboxMessageListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private static let customListItemId = "CustomInboxListItem"
    private static let customPaginationItemId = "CustomInboxPaginationItem"
    
    private let feed: InboxMessageFeed
    
    // MARK: Theme
    
    private var theme: CourierInboxTheme = .defaultLight
    
    // MARK: Custom Views
    
    private let customListItem: CourierInbox.CustomListItemView?
    private let customLoadingState: CourierInbox.CustomLoadingStateView?
    private let customEmptyState: CourierInbox.CustomEmptyStateView?
    private let customErrorState: CourierInbox.CustomErrorStateView?
    private let customPaginationItem: CourierInbox.CustomPaginationItemView?
    private var activeStateView: UIView? = nil
    
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
        if customListItem != nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: InboxMessageListView.customListItemId)
        }
        if customPaginationItem != nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: InboxMessageListView.customPaginationItemId)
        }
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
            self?.retry()
        }
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var stateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: Authentication
    
    private var authListener: CourierAuthenticationListener? = nil
    
    // MARK: State
    
    private var isEmptyState: Bool {
        switch state {
        case .empty: return true
        default: return false
        }
    }
    
    private var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                if let customLoadingState = customLoadingState {
                    loadingIndicator.stopAnimating()
                    tableView.isHidden = true
                    infoView.isHidden = true
                    showStateView(customLoadingState(feed))
                } else {
                    hideStateView()
                    loadingIndicator.startAnimating()
                    tableView.isHidden = true
                    infoView.isHidden = true
                }
            case .error(let message):
                if let customErrorState = customErrorState {
                    loadingIndicator.stopAnimating()
                    tableView.isHidden = true
                    infoView.isHidden = true
                    showStateView(customErrorState(feed, message, { [weak self] in
                        self?.retry()
                    }))
                } else {
                    hideStateView()
                    loadingIndicator.stopAnimating()
                    tableView.isHidden = true
                    infoView.isHidden = false
                    infoView.updateView(state, actionTitle: "Retry", contentTitle: "No messages found")
                }
            case .content:
                hideStateView()
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                infoView.isHidden = true
            case .empty:
                if let customEmptyState = customEmptyState {
                    loadingIndicator.stopAnimating()
                    tableView.isHidden = true
                    infoView.isHidden = true
                    showStateView(customEmptyState(feed, { [weak self] in
                        self?.retry()
                    }))
                } else {
                    hideStateView()
                    loadingIndicator.stopAnimating()
                    tableView.isHidden = false
                    infoView.isHidden = false
                    infoView.updateView(state, actionTitle: "Retry", contentTitle: "No messages found")
                }
            }
        }
    }
    
    // MARK: Init
    
    public init(
        feed: InboxMessageFeed,
        customListItem: CourierInbox.CustomListItemView? = nil,
        customLoadingState: CourierInbox.CustomLoadingStateView? = nil,
        customEmptyState: CourierInbox.CustomEmptyStateView? = nil,
        customErrorState: CourierInbox.CustomErrorStateView? = nil,
        customPaginationItem: CourierInbox.CustomPaginationItemView? = nil,
        didClickInboxMessageAtIndex: @escaping (_ message: InboxMessage, _ index: Int) -> Void,
        didLongPressInboxMessageAtIndex: @escaping (_ message: InboxMessage, _ index: Int) -> Void,
        didClickInboxActionForMessageAtIndex: @escaping (_ action: InboxAction, _ message: InboxMessage, _ index: Int) -> Void,
        didScrollInbox: @escaping (UIScrollView) -> Void
    ) {
        self.feed = feed
        self.customListItem = customListItem
        self.customLoadingState = customLoadingState
        self.customEmptyState = customEmptyState
        self.customErrorState = customErrorState
        self.customPaginationItem = customPaginationItem
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didLongPressInboxMessageAtIndex = didLongPressInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.feed = .feed
        self.customListItem = nil
        self.customLoadingState = nil
        self.customEmptyState = nil
        self.customErrorState = nil
        self.customPaginationItem = nil
        self.didClickInboxMessageAtIndex = { _, _ in }
        self.didLongPressInboxMessageAtIndex = { _, _ in }
        self.didClickInboxActionForMessageAtIndex = { _, _, _ in }
        self.didScrollInbox = { _ in }
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.feed = .feed
        self.customListItem = nil
        self.customLoadingState = nil
        self.customEmptyState = nil
        self.customErrorState = nil
        self.customPaginationItem = nil
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
        
        state = .loading
        addTableView()
        addLoadingIndicator()
        addInfoView()
        addStateContainer()
        traitCollectionDidChange(nil)
    }
    
    private func retry() {
        state = .loading
        onRefresh()
    }
    
    internal func setTheme(_ theme: CourierInboxTheme) {
        self.theme = theme
        reloadViews()
    }
    
    internal func setLoading() {
        self.state = .loading
    }
    
    internal func setError(_ message: String) {
        self.state = .error(message)
    }
    
    internal func setInbox(messages: [InboxMessage], canPaginate: Bool) {
        self.manuallyArchivedMessageId = nil
        self.inboxMessages = messages
        self.canPaginate = canPaginate
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        self.state = inboxMessages.isEmpty ? .empty : .content
        self.openVisibleMessages()
    }
    
    internal func addPage(messages: [InboxMessage], canPaginate: Bool) {
        self.manuallyArchivedMessageId = nil
        
        if messages.isEmpty {
            self.canPaginate = false
            self.tableView.reloadData()
            return
        }
        
        let insertionIndex = inboxMessages.count
        self.inboxMessages.insert(contentsOf: messages, at: insertionIndex)
        self.state = inboxMessages.isEmpty ? .empty : .content
        
        let indexPaths = (insertionIndex..<insertionIndex + messages.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        self.tableView.insertRows(at: indexPaths, with: .automatic)
        
        let couldPaginate = self.canPaginate
        self.canPaginate = canPaginate
        if couldPaginate && !canPaginate {
            tableView.deleteSections(IndexSet(integer: 1), with: .automatic)
        }
        
        self.openVisibleMessages()
    }
    
    internal func addMessage(at index: Int, message: InboxMessage) {
        guard index >= 0 && index <= inboxMessages.count else {
            print("Error: Index \(index) is out of bounds for inboxMessages.")
            return
        }
        
        self.manuallyArchivedMessageId = nil
        self.inboxMessages.insert(message, at: index)
        self.state = inboxMessages.isEmpty ? .empty : .content
        
        guard index >= 0 && index <= tableView.numberOfRows(inSection: 0) else {
            Task {
                await Courier.shared.client?.log("Error: CourierInboxListView index \(index) is out of bounds.")
            }
            self.tableView.reloadData()
            self.state = self.inboxMessages.isEmpty ? .empty : .content
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: theme.messageAnimationStyle)
        self.openVisibleMessages()
    }
    
    internal func updateMessage(at index: Int, message: InboxMessage) {
        if !canUpdateMessages(index: index, messageId: message.messageId) {
            return
        }
        
        self.inboxMessages[index] = message
        self.state = inboxMessages.isEmpty ? .empty : .content
        
        let indexPath = IndexPath(row: index, section: 0)
        if self.customListItem != nil {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? CourierInboxTableViewCell
            cell?.refreshMessage(message)
        }
    }
    
    internal func removeMessage(at index: Int, message: InboxMessage) {
        guard index >= 0 && index < inboxMessages.count, inboxMessages[index].messageId == message.messageId else {
            print("Invalid index or message ID mismatch. Cannot remove message.")
            return
        }
        
        if !canUpdateMessages(index: index, messageId: message.messageId) {
            return
        }
        
        inboxMessages.remove(at: index)
        
        if (Courier.agent.isReactNative()) {
            self.tableView.reloadData()
            self.state = self.inboxMessages.isEmpty ? .empty : .content
            return
        }
        
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
    
    private func addStateContainer() {
        addSubview(stateContainer)
        
        NSLayoutConstraint.activate([
            stateContainer.topAnchor.constraint(equalTo: topAnchor),
            stateContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            stateContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            stateContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func showStateView(_ view: UIView) {
        activeStateView?.removeFromSuperview()
        activeStateView = view
        view.translatesAutoresizingMaskIntoConstraints = false
        stateContainer.isHidden = false
        stateContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stateContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: stateContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
        ])
    }
    
    private func hideStateView() {
        activeStateView?.removeFromSuperview()
        activeStateView = nil
        stateContainer.isHidden = true
    }
    
    private func renderCustomView(in cell: UITableViewCell, view: UIView, selectionStyle: UITableViewCell.SelectionStyle = .none) {
        cell.selectionStyle = selectionStyle
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
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
        if indexPath.section == 0 {
            let index = indexPath.row
            let message = inboxMessages[index]
            
            if let customListItem = self.customListItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: InboxMessageListView.customListItemId, for: indexPath)
                renderCustomView(in: cell, view: customListItem(message, index))
                return cell
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxTableViewCell.id, for: indexPath) as? CourierInboxTableViewCell {
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
            if let customPaginationItem = self.customPaginationItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: InboxMessageListView.customPaginationItemId, for: indexPath)
                renderCustomView(in: cell, view: customPaginationItem(feed))
                return cell
            }
            
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
        if let messageCell = cell as? CourierInboxTableViewCell {
            messageCell.applyListItemBackgroundColor(theme.listItemBackgroundColor)
        }
        if indexPath.section == 1 && self.canPaginate {
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
        if indexPath.section == 0 {
            let index = indexPath.row
            let message = self.inboxMessages[index]
            message.markAsClicked()
            self.didClickInboxMessageAtIndex(message, index)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private var manuallyArchivedMessageId: String? = nil
    
    private func archiveCell(at index: Int) {
        let message = inboxMessages[index]
        removeMessage(at: index, message: message)
        self.manuallyArchivedMessageId = message.messageId
        
        Task {
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
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let message = inboxMessages[indexPath.row]
        
        if self.canSwipePages || message.isArchived || self.customListItem != nil {
            return nil
        }
        
        let style = message.isRead ? self.theme.readingSwipeActionStyle.read : self.theme.readingSwipeActionStyle.unread
        let actionTitle = message.isRead ? "Unread" : "Read"
        
        let toggleReadAction = UIContextualAction(style: .normal, title: actionTitle) { [weak self] (_, _, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.readCell(isRead: message.isRead, at: indexPath.row)
            completionHandler(true)
        }
        
        toggleReadAction.backgroundColor = style.color
        toggleReadAction.image = style.icon
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [toggleReadAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        return swipeConfiguration
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let message = inboxMessages[indexPath.row]
        
        if self.canSwipePages || message.isArchived || self.customListItem != nil {
            return nil
        }
        
        let archiveAction = UIContextualAction(style: .destructive, title: "Archive") { [weak self] (_, _, completionHandler) in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.archiveCell(at: indexPath.row)
            completionHandler(true)
        }
        
        let style = self.theme.archivingSwipeActionStyle.archive
        archiveAction.backgroundColor = style.color
        archiveAction.image = style.icon
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [archiveAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        return swipeConfiguration
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollInbox(scrollView)
        self.openVisibleMessages()
    }
    
    private func getVisibleMessages(messages: [InboxMessage], indices: [IndexPath]) -> [InboxMessage] {
        indices.compactMap { indexPath in
            let index = indexPath.row
            guard index >= 0 && index < inboxMessages.count else { return nil }
            let message = inboxMessages[index]
            return message.isOpened ? nil : message
        }
    }
    
    private func openVisibleMessages() {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        Task { @CourierActor in
            let messages = await feed == .feed ? Courier.shared.feedMessages : Courier.shared.archivedMessages
            let messagesToOpen = await getVisibleMessages(messages: messages, indices: visibleIndexPaths)
            for message in messagesToOpen {
                try await Courier.shared.openMessage(message.messageId)
            }
        }
    }
    
    public func scrollToTop(animated: Bool) {
        if self.inboxMessages.isEmpty {
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
        self.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        if self.customListItem == nil {
            tableView.separatorStyle = theme.cellStyle.separatorStyle
            tableView.separatorInset = theme.cellStyle.separatorInsets
            tableView.separatorColor = theme.cellStyle.separatorColor
        } else {
            tableView.separatorStyle = .none
            tableView.separatorInset = .zero
            tableView.separatorColor = nil
        }
        tableView.refreshControl?.tintColor = theme.loadingColor
        loadingIndicator.color = theme.loadingColor
        infoView.setTheme(theme)
        
        tableView.appendAccessibilityIdentifier("InboxMessage")
        loadingIndicator.appendAccessibilityIdentifier("InboxMessage")
        
        self.tableView.reloadData()
    }
    
    deinit {
        Task { [self] in
            await self.authListener?.remove()
        }
    }
}
