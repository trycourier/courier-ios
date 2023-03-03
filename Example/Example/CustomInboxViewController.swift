//
//  CustomInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 2/28/23.
//

import UIKit
import Courier

class CustomInboxViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stateLabel: UILabel!
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    enum State {
        case loading
        case error
        case content
        case empty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Inbox"
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)
        
        self.inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: {
                self.setState(.loading)
            },
            onError: { error in
                self.setState(.error, error: String(describing: error))
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                
                print(messages.count, unreadMessageCount, totalMessageCount, canPaginate)
                
                self.setState(messages.isEmpty ? .empty : .content)
                self.canPaginate = canPaginate
                self.inboxMessages = messages
                self.collectionView.reloadData()
                
            }
        )
        
    }
    
    @objc private func onPullRefresh() {
        Courier.shared.refreshInbox {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func setState(_ state: State, error: String? = nil) {
        switch (state) {
        case .loading:
            self.collectionView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = "Loading..."
        case .error:
            self.collectionView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = error ?? "Error"
        case .content:
            self.collectionView.isHidden = false
            self.stateLabel.isHidden = true
            self.stateLabel.text = ""
        case .empty:
            self.collectionView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = "No messages found"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.canPaginate ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.inboxMessages.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomInboxCollectionViewCell.id, for: indexPath as IndexPath) as! CustomInboxCollectionViewCell
        
        if (indexPath.section == 0) {
            let message = inboxMessages[indexPath.row]
            cell.textLabel.text = "\(indexPath.row) :: \(message.title ?? "No title") :: \(message.preview ?? "No body")"
        } else {
            cell.textLabel.text = "Loading..."
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            Task {
                Courier.shared.fetchNextPageOfMessages()
            }
        }
        
    }
    
    deinit {
        self?.inboxListener.
    }

}
