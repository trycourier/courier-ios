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
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)

        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)

        collectionView.backgroundColor = .orange

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        self.collectionView = collectionView
        
        // Add state label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc private func onPullRefresh() {
        Courier.shared.refreshInbox {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
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
            cell.contentView.backgroundColor = message.isRead ? .green : .red
        } else {
            cell.label.text = "Loading..."
            cell.contentView.backgroundColor = .clear
        }
        
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            Courier.shared.fetchNextPageOfMessages()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let message = inboxMessages[index]
        delegate?.didClickMessageAtIndex?(message: message, index: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.inboxDidScroll?(scrollView: scrollView)
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
