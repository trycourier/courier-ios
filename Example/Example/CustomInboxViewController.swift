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
        
        Courier.shared.isDebugging = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)
        
        // Courier Inbox
        Courier.shared.addInboxListener(
            onInitialLoad: {
                self.setState(.loading)
            },
            onError: { error in
                self.setState(.error, error: String(describing: error))
            },
            onMessagesChanged: { newMessage, previousMessages, nextPageOfMessages, unreadMessageCount, totalMessageCount, canPaginate in
                
                print(newMessage ?? "No new message", previousMessages.count, nextPageOfMessages.count, unreadMessageCount, totalMessageCount, canPaginate)
                
                if (Courier.shared.inboxMessages?.isEmpty ?? true) {
                    self.setState(.empty)
                } else {
                    self.setState(.content)
                }
                
                self.canPaginate = canPaginate
                
                if let message = newMessage {
                    self.inboxMessages = [message] + previousMessages
                } else {
                    self.inboxMessages = previousMessages + nextPageOfMessages
                }
                
                self.collectionView.reloadData()
                
            }
        )
        
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
            Courier.shared.fetchNextPageOfMessages()
        }
        
    }

}
