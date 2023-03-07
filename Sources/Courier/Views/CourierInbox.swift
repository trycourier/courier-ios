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
        let collectionView = makeCollectionView()
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        self.tableView = collectionView
        
        // Add state label
        let label = makeLabel()
        addSubview(label)
        let defaultMargin: CGFloat = 20
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: defaultMargin),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -defaultMargin),
        ])
        self.stateLabel = label
        
        self.state = .loading
        
        self.makeListener()
        
    }
    
    private func makeCollectionView() -> UITableView {
        
        // Create sized layout
//        let size = NSCollectionLayoutSize(
//            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
//            heightDimension: NSCollectionLayoutDimension.estimated(44)
//        )
//
//        let item = NSCollectionLayoutItem(layoutSize: size)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = .zero
//        section.interGroupSpacing = 0
//
//        let headerFooterSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(0)
//        )
//
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerFooterSize,
//            elementKind: "SectionHeaderElementKind",
//            alignment: .top
//        )
//
//        section.boundarySupplementaryItems = [sectionHeader]
//
//        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // Create the collection view
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)
        tableView.register(CustomInboxCollectionViewCell.self, forCellReuseIdentifier: CustomInboxCollectionViewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
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
        if (newMessages.first?.messageId != inboxMessages.first?.messageId) {
            inboxMessages = newMessages
            let indexPath = IndexPath(row: 0, section: 0)
            tableView?.insertRows(at: [indexPath], with: .left)
            return
        }
        
        // Set the messages
        inboxMessages = newMessages
        tableView?.reloadData()
        
    }
    
    private func getPaginationTrigger() -> CGFloat {
        return self.frame.height / 3
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CustomInboxCollectionViewCell.id, for: indexPath) as? CustomInboxCollectionViewCell {
            
            if (indexPath.section == 0) {
                let message = inboxMessages[indexPath.row]
                cell.label.text = "\(indexPath.row) :: \(message.title ?? "No title") :: \(message.preview ?? "No body")"
                cell.contentView.backgroundColor = message.isRead ? .clear : .blue
            } else {
                cell.label.text = "Loading..."
                cell.contentView.backgroundColor = .clear
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let indexToPageAt = inboxMessages.count - Int(CoreInbox.defaultPaginationLimit / 4)
        
        // Only fetch if we are safe to
        if (indexPath.row == indexToPageAt && Courier.shared.inbox.canPage()) {
            Courier.shared.fetchNextPageOfMessages()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let message = inboxMessages[index]
        delegate?.didClickInboxMessageAtIndex?(message: message, index: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollInbox?(scrollView: scrollView)
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
