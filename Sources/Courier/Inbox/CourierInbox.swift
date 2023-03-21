//
//  CourierInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/6/23.
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
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierInboxTheme = CourierInboxTheme.defaultLight
    
    // MARK: Datasource
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    // MARK: Repository
    
    private lazy var brandsRepo = BrandsRepository()
    
    // MARK: Subviews
    
    @objc public let tableView = UITableView()
    private let courierBar = CourierBar()
    private let infoView = CourierInboxInfoView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: Constraints
    
    private var infoViewY: NSLayoutConstraint? = nil
    private var courierBarBottom: NSLayoutConstraint? = nil
    
    // MARK: State
    
    enum State {
        
        case loading
        case error(_ error: Error)
        case content
        case empty
        
        func error() -> Error? {
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
                self.infoView.updateView(state)
            case .content:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.infoView.isHidden = true
            case .empty:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
                self.infoView.updateView(state)
            }
            
            // Scroll to top if needed
            if ("\(oldValue)" != "\(state)") {
                self.scrollToTop(animated: false)
            }
            
        }
    }
    
    // MARK: Init
    
    @objc public init(lightTheme: CourierInboxTheme = .defaultLight, darkTheme: CourierInboxTheme = .defaultDark) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        super.init(frame: .zero)
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
        
        Task {
            
            // Set state
            state = .loading
            
            // Get the brands if possible
            // Will silently fail
            await fetchBrands()

            // Add the views
            addTableView()
            addLoadingIndicator()
            addInfoView()
            addCourierBar()
            
            // Refreshes theme
            traitCollectionDidChange(nil)
            
            // Init the listener
            makeListener()
            
        }
        
    }
    
    private func refreshCourierBarIfNeeded() {
        
        if (!courierBar.isHidden) {
         
            // Set the courier bar background color
            if let backgroundColor = superview?.backgroundColor {
                courierBar.setColors(with: backgroundColor)
            }
            
            // Add content inset
            tableView.verticalScrollIndicatorInsets.bottom = courierBar.frame.height
            tableView.contentInset.bottom = courierBar.frame.height
            
            // Update position
            courierBarBottom?.constant = -(tableView.adjustedContentInset.bottom - courierBar.frame.height)
            courierBar.layoutIfNeeded()
            
            // Update infoView position
            infoViewY?.constant = -(courierBar.frame.height / 2)
            infoView.layoutIfNeeded()
            
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        refreshCourierBarIfNeeded()
        
    }
    
    private func addCourierBar() {
        
        courierBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(courierBar)
        
        courierBarBottom = courierBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            courierBarBottom!,
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: CourierInboxListItem.id, bundle: Bundle.module)
        tableView.register(nib, forCellReuseIdentifier: CourierInboxListItem.id)
        tableView.register(CourierInboxPaginationCell.self, forCellReuseIdentifier: CourierInboxPaginationCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Add the refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
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
        
        // Refresh the inbox
        infoView.onButtonClick = { [weak self] in
            self?.state = .loading
            self?.onRefresh()
        }
        
        addSubview(infoView)
        
        infoViewY = infoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            infoViewY!,
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CourierInboxTheme.margin),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CourierInboxTheme.margin),
        ])
        
    }
    
    private func fetchBrands() async {
        let _ = await [
            lightTheme.attachBrand(),
            darkTheme.attachBrand()
        ]
    }
    
    private func makeListener() {
        
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
            self.tableView.insertRows(at: [indexPath], with: theme.messageAnimationStyle)
            return
        }
        
        // Set the messages
        self.inboxMessages = newMessages
        self.tableView.reloadData()
        
    }
    
    @objc private func onRefresh() {
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: CourierInboxListItem.id, for: indexPath) as? CourierInboxListItem {
                
                let index = indexPath.row
                let message = inboxMessages[index]
                
                cell.setMessage(message, theme) { [weak self] inboxAction in
                    self?.delegate?.didClickInboxActionForMessageAtIndex?(
                        action: inboxAction,
                        message: message,
                        index: index
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
        
        tableView.separatorStyle = theme.cellStyles.separatorStyle
        tableView.separatorInset = theme.cellStyles.separatorInsets
        tableView.separatorColor = theme.cellStyles.separatorColor
        
        tableView.refreshControl?.tintColor = theme.loadingColor
        loadingIndicator.color = theme.loadingColor
        
        infoView.setTheme(theme)
        courierBar.setTheme(theme)
        
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
        self.inboxListener?.remove()
    }

}
