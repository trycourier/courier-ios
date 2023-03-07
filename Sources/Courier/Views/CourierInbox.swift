//
//  CourierInbox.swift
//  
//
//  Created by Michael Miller on 3/6/23.
//

import UIKit

@objc open class CourierInbox: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public var delegate: CourierInboxDelegate? = nil
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    private var collectionView: UICollectionView? = nil
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
                self.collectionView?.isHidden = true
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = "Loading..."
            case .error:
                self.collectionView?.isHidden = true
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = String(describing: state.value() ?? "Error")
            case .content:
                self.collectionView?.isHidden = false
                self.stateLabel?.isHidden = true
                self.stateLabel?.text = nil
            case .empty:
                self.collectionView?.isHidden = true
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
        self.collectionView = collectionView
        
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
    
    private func makeCollectionView() -> UICollectionView {
        
        // Create sized layout
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(44)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = 0

        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(0)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: "SectionHeaderElementKind",
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [sectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // Create the collection view
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // Add the refresh control
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)
        
        return collectionView
        
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
            onMessagesChanged: { [weak self] messages, unreadMessageCount, totalMessageCount, canPaginate in
                self?.state = messages.isEmpty ? .empty : .content
                self?.canPaginate = canPaginate
                self?.inboxMessages = messages
                self?.collectionView?.reloadData()
            }
        )
        
    }
    
    private func getPaginationTrigger() -> CGFloat {
        return self.frame.height / 3
    }
    
    @objc private func onPullRefresh() {
        Courier.shared.refreshInbox {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.canPaginate ? 2 : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.inboxMessages.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomInboxCollectionViewCell.id, for: indexPath as IndexPath) as! CustomInboxCollectionViewCell
        
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
    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if (indexPath.section == 1) {
//            Courier.shared.fetchNextPageOfMessages()
//        }
//    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let message = inboxMessages[index]
        delegate?.didClickInboxMessageAtIndex?(message: message, index: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Call delegate
        delegate?.didScrollInbox?(scrollView: scrollView)
        
        // Handle pagination
        let distanceToBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        if (distanceToBottom < getPaginationTrigger()) {
            Courier.shared.fetchNextPageOfMessages()
        }
        
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
