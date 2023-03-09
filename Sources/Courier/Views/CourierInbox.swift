//
//  CourierInbox.swift
//  
//
//  Created by Michael Miller on 3/6/23.
//

import UIKit

@objc open class CourierInbox: UIView, UITableViewDelegate, UITableViewDataSource {
    
    public var delegate: CourierInboxDelegate? = nil
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    private var tableView: UITableView? = nil
    private var stateLabel: UILabel? = nil
    
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
                self.tableView?.isHidden = true
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = "Loading..."
            case .error:
                self.tableView?.isHidden = true
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = String(describing: state.value() ?? "Error")
            case .content:
                self.tableView?.isHidden = false
                self.stateLabel?.isHidden = true
                self.stateLabel?.text = nil
            case .empty:
                self.tableView?.isHidden = true
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = "No messages found"
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {

        // Add the collection view
        let tableView = makeTableView()
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        self.tableView = tableView
        
        // Add state label
        let label = makeLabel()
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CourierInboxTheme.margin),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CourierInboxTheme.margin),
        ])
        self.stateLabel = label
        
        self.state = .loading
        
        self.makeListener()
        
    }
    
    private func makeTableView() -> UITableView {
        
        // Create the table view
        let tableView = UITableView()
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
        
        return tableView
        
    }
    
    private func makeLabel() -> UILabel {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
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
    
    private func reloadMessages(_ newMessages: [InboxMessage]) {
        
        // Check if we need to insert
        let didInsert = newMessages.count - self.inboxMessages.count == 1
        if (newMessages.first?.messageId != self.inboxMessages.first?.messageId && didInsert) {
            self.inboxMessages = newMessages
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView?.insertRows(at: [indexPath], with: .left)
            return
        }
        
        // Set the messages
        self.inboxMessages = newMessages
        self.tableView?.reloadData()
        
    }
    
    @objc private func onPullRefresh() {
        Courier.shared.refreshInbox {
            self.tableView?.refreshControl?.endRefreshing()
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
        self.tableView?.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView?.reloadData()
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
