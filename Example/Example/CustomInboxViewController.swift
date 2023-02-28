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
            onMessagesChanged: { unreadMessageCount, totalMessageCount, previousMessages, newMessages, canPaginate in
                
                if (canPaginate) {
                    Courier.shared.fetchNextPageOfMessages()
                }
                
                if (newMessages.count == 1) {
                    self.inboxMessages = newMessages + previousMessages
                } else {
                    self.inboxMessages = previousMessages + newMessages
                }
                
                // TODO: Move to main thread
                // TODO: Clean this up
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }
        )
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inboxMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomInboxCollectionViewCell.id, for: indexPath as IndexPath) as! CustomInboxCollectionViewCell
        let message = inboxMessages[indexPath.row]
        cell.textLabel.text = "\(message.messageId) :: \(message.title ?? "No title")"
        return cell
        
    }

}
