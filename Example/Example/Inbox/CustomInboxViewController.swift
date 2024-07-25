//
//  CustomInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 2/28/23.
//

import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        view.addSubview(tableView)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.id)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: {
                self.setState(.loading)
            },
            onError: { error in
                self.setState(.error, error: String(describing: error))
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                self.setState(messages.isEmpty ? .empty : .content)
                self.canPaginate = canPaginate
                self.inboxMessages = messages
                self.tableView.reloadData()
            }
        )

        view.addSubview(stateLabel)
        
        NSLayoutConstraint.activate([
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    @objc private func onPullRefresh() {
        Task {
            try await Courier.shared.refreshInbox()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func setState(_ state: State, error: String? = nil) {
        switch (state) {
        case .loading:
            self.tableView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = "Loading..."
        case .error:
            self.tableView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = error ?? "Error"
        case .content:
            self.tableView.isHidden = false
            self.stateLabel.isHidden = true
            self.stateLabel.text = ""
        case .empty:
            self.tableView.isHidden = true
            self.stateLabel.isHidden = false
            self.stateLabel.text = "No messages found"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.canPaginate ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.inboxMessages.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as! CustomTableViewCell
            let message = self.inboxMessages[indexPath.row]
            cell.label.text = message.toJson()
            cell.contentView.backgroundColor = !message.isRead ? .green : .clear
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.id, for: indexPath) as! LoadingTableViewCell
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let message = inboxMessages[indexPath.row]
            message.isRead ? message.markAsUnread() : message.markAsRead()
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            
            Task {
                
                do {
                    try await Courier.shared.fetchNextInboxPage()
                } catch {
                    Courier.shared.client?.options.log(error.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
