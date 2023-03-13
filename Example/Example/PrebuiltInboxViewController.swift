//
//  PrebuiltInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 3/6/23.
//

import UIKit
import Courier

struct Item {
    let title: String
    let body: String
}

class PrebuiltInboxViewController: UIViewController, CourierInboxDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var courierInbox: CourierInbox!
    
    let titles = [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
        "Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore ",
        "Ullamco laboris nisi ut aliquip ex ea commodo consequat nisi ut aliquip ex ea commodo consequat duis aute irure dolor",
        "sunt in culpa qui officia deserunt mollit anim id est laborum."
    ]
    
    let messages = [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco",
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Lorem ipsum dolor sit amet"
    ]
    
    lazy var items: [Item] = {
        var items: [Item] = []
        for i in 0...99 {
            let item = Item(title: self.titles.randomElement()!, body: self.messages.randomElement()!)
            items.append(item)
        }
        return items
    }()
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Set Theme", style: .plain, target: self, action: #selector(setTheme))
        
//        courierInbox.removeFromSuperview()
        courierInbox.delegate = self
        
        setTheme()
        
//        addTableView()
        
    }
    
    @objc private func setTheme() {
        
        let theme = CourierInboxTheme(
            messageAnimationStyle: .right,
            unreadIndicatorBarColor: .systemPink,
            loadingIndicatorColor: .systemGreen,
            titleFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 20),
                color: .red
            ),
            timeFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 30),
                color: .green
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Al Nile Bold", size: 14)!,
                color: .blue
            ),
            detailTitleFont: CourierInboxFont(
                font: UIFont(name: "Al Nile Bold", size: 22)!,
                color: .green
            ),
            actionButtonFont: CourierInboxFont(
                font: UIFont(name: "Al Nile Bold", size: 13)!,
                color: .lightGray
            ),
            actionButtonBackgroundColor: .systemOrange,
            cellStyles: CourierInboxCellStyles(
                separatorStyle: .singleLine,
                separatorColor: .purple
            )
        )
        courierInbox.lightTheme = theme
        courierInbox.darkTheme = theme
        
    }
    
    private func addTableView() {
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TestCell.self, forCellReuseIdentifier: TestCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
//        courierInbox.scrollToTop(animated: true)
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TestCell.id, for: indexPath) as? TestCell {
            cell.setItem(item: items[indexPath.row], width: tableView.frame.width)
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = Item(title: self.titles.randomElement()!, body: self.messages.randomElement()!)
//        items.insert(item, at: 0)
        tableView.reloadData()
    }

}
