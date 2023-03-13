//
//  CourierInbox.swift
//  
//
//  Created by Michael Miller on 3/6/23.
//

import UIKit

/**
 A super simple way to implement notifications into your app
 TODO: How to use the inbox?
 TODO: how to send messages to it?
 TODO: Link to docs?
 */
@objc open class CourierInbox: UIView, UITableViewDelegate, UITableViewDataSource {
    
    /**
     Attached the delegate needed to handle various interactions
     More info can be found here: ``CourierInboxDelegate``
     */
    @objc public var delegate: CourierInboxDelegate? = nil
    
    // MARK: Theme
    
    @objc public var lightTheme = CourierInboxTheme.defaultLight {
        didSet {
            traitCollectionDidChange(nil)
        }
    }
    
    @objc public var darkTheme = CourierInboxTheme.defaultDark {
        didSet {
            traitCollectionDidChange(nil)
        }
    }
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    internal static var theme: CourierInboxTheme = CourierInboxTheme.defaultLight
    
    // MARK: Datasource
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    // MARK: Subviews
    
    private let tableView = UITableView()
    private let infoView = InfoView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: State
    
    enum State {
        
        case loading
        case error(error: Error)
        case content
        case empty
        
        func value() -> Any? {
            switch self {
            case .error(let value):
                return value
            default:
                return nil
            }
        }
        
    }
    
    private var state: State = .loading {
        didSet {
            switch (state) {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = true
            case .error:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
//                self.stateLabel.isHidden = false
//                self.stateLabel.text = String(describing: state.value() ?? "Error")
            case .content:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.infoView.isHidden = true
            case .empty:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
            }
        }
    }
    
    private lazy var timer = Timer()
    
    // MARK: Init
    
    // TODO: Programatic implementation

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Refresh light / dark mode
        traitCollectionDidChange(nil)

        // Add the views
        addTableView()
        addLoadingIndicator()
        addInfoView()
        
        // Set state
        state = .loading
        
        // Init the listener
        makeListener()
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.updateVisibleCellTimes()
        })
        
    }
    
    // Gets all the currently visible cells and refreshes their times
    private func updateVisibleCellTimes() {
        tableView.indexPathsForVisibleRows?.forEach { path in
            let cell = tableView.cellForRow(at: path) as? CourierInboxTableViewCell
            cell?.updateTime()
        }
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourierInboxTableViewCell.self, forCellReuseIdentifier: CourierInboxTableViewCell.id)
        tableView.register(CourierInboxPaginationCell.self, forCellReuseIdentifier: CourierInboxPaginationCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Add the refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addLoadingIndicator() {
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    private func addInfoView() {
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(infoView)
        
        NSLayoutConstraint.activate([
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CourierInboxTheme.margin),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CourierInboxTheme.margin),
        ])
        
    }
    
    private func makeListener() {
        
        self.inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: { [weak self] in
                self?.state = .loading
            },
            onError: { [weak self] error in
                self?.state = .error(error: error)
            },
            onMessagesChanged: { [weak self] newMessages, unreadMessageCount, totalMessageCount, canPaginate in
                self?.state = newMessages.isEmpty ? .empty : .content
                self?.canPaginate = canPaginate
                self?.reloadMessages(newMessages)
            }
        )
        
    }
    
    // MARK: Reload
    
    /**
     Adds the new message at top if needed
     Otherwise will reload all the messages with the new datasource
     */
    private func reloadMessages(_ newMessages: [InboxMessage]) {
        
        // Check if we need to insert
        let didInsert = newMessages.count - self.inboxMessages.count == 1
        if (newMessages.first?.messageId != self.inboxMessages.first?.messageId && didInsert) {
            self.inboxMessages = newMessages
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: CourierInbox.theme.newMessageAnimationStyle)
            return
        }
        
        // Set the messages
        self.inboxMessages = newMessages
        self.tableView.reloadData()
        
    }
    
    @objc private func onPullRefresh() {
        Courier.shared.refreshInbox {
            self.tableView.refreshControl?.endRefreshing()
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
                let message = inboxMessages[indexPath.row]
                cell.setMessage(message, width: tableView.bounds.width)
                return cell
            }
            
        } else {
            
            // Pagination cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxPaginationCell.id, for: indexPath) as? CourierInboxPaginationCell {
                return cell
            }
            
        }
        
        return UITableViewCell()
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let indexToPageAt = self.inboxMessages.count - Int(CoreInbox.defaultPaginationLimit / 3)
        
        // Only fetch if we are safe to
        if (indexPath.row == indexToPageAt && Courier.shared.inbox.canPage()) {
            Courier.shared.fetchNextPageOfMessages()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let index = indexPath.row
            let message = self.inboxMessages[index]
            self.delegate?.didClickInboxMessageAtIndex?(message: message, index: index)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.didScrollInbox?(scrollView: scrollView)
    }
    
    @objc public func scrollToTop(animated: Bool) {
        self.tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
    }
    
    // TODO: Handle rotation and dark mode
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handles setting the theme of the Inbox
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
        }
        
    }
    
    private func setTheme(isDarkMode: Bool) {
        
        CourierInbox.theme = isDarkMode ? darkTheme : lightTheme
        
        tableView.separatorStyle = CourierInbox.theme.cellStyles.separatorStyle
        tableView.separatorInset = CourierInbox.theme.cellStyles.separatorInsets
        tableView.separatorColor = CourierInbox.theme.cellStyles.separatorColor
        
        reloadCells()
        
    }
    
    private func reloadCells() {
        if let paths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: paths, with: .none)
        }
    }
    
    /**
     Kills the listener and timer if the view is deallocated
     */
    deinit {
        self.timer.invalidate()
        self.inboxListener?.remove()
    }

}

private class InfoView: UIView {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .roundedRect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .orange
        
        addStack()
        addTitle()
        addButton()
        
    }
    
    private func addStack() {
        
        stackView.spacing = CourierInboxTheme.margin * 2
        stackView.axis = .vertical
        stackView.backgroundColor = .red
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
    
    private func addTitle() {
        
        titleLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco"
        
        titleLabel.backgroundColor = .gray
        
        titleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(titleLabel)
        
    }
    
    private func addButton() {
        
        actionButton.setTitle("Example", for: .normal)
        
        stackView.addArrangedSubview(actionButton)
        
    }
    
}
