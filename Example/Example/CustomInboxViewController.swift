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
    
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(CustomInboxCollectionViewCell.self, forCellWithReuseIdentifier: CustomInboxCollectionViewCell.id)
        
        // Courier Inbox
        Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Inbox Listener Loading")
            },
            onError: { error in
                print("Inbox Listener Error: \(error)")
            },
            onMessagesChanged: { newMessage, previousMessages, nextPageOfMessages, unreadMessageCount, totalMessageCount, canPaginate in
                
                self.canPaginate = canPaginate
                
                if let message = newMessage {
                    self.inboxMessages = [message] + previousMessages
                } else {
                    self.inboxMessages = previousMessages + nextPageOfMessages
                }
                
                // TODO: Main thread?
                // TODO: How do we animate?
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
        )
        
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
