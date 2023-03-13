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
        
        Courier.shared.addInboxListener(onMessagesChanged: { messages, _, _, _ in
            
            if let message = messages.first {
                
                let dateFormatter = DateFormatter()

                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

                let updatedAtStr = message.created ?? ""
                let updatedAt = dateFormatter.date(from: updatedAtStr)
                
                let time = self.getTimeSince(date: updatedAt ?? Date())
                print(time, updatedAt, message.created)
                
            }
            
        })
        
//        addTableView()
        
    }
    
    func getTimeSince(date: Date, isShort: Bool = false) -> String {
        var formattedString = String()
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(date))
        
        let twoSeconds = 2
        let minute = 60
        let twoMinutes = minute * 2
        let hour = 60 * minute
        let twoHours = hour * 2
        let day = 24 * hour
        let twoDays = day * 2
        let week = 7 * day
        let twoWeeks = week * 2
        let month = 4 * week
        let twoMonths = month * 2
        let year = 12 * month
        let twoYears = year * 2
        
        let secondString = isShort ? "s ago" : " second ago"
        let secondsString = isShort ? "s ago" : " seconds ago"
        let minuteString = isShort ? "m ago" : " minute ago"
        let minutesString = isShort ? "m ago" : " minutes ago"
        let hourString = isShort ? "h ago" : " hour ago"
        let hoursString = isShort ? "h ago" : " hours ago"
        let dayString = isShort ? "d ago" : " day ago"
        let daysString = isShort ? "d ago" : " days ago"
        let weekString = isShort ? "w ago" : " week ago"
        let weeksString = isShort ? "w ago" : " weeks ago"
        let monthString = isShort ? "mo ago" : " month ago"
        let monthsString = isShort ? "mo ago" : " months ago"
        let yearString = isShort ? "y ago" : " year ago"
        let yearsString = isShort ? "y ago" : " years ago"
        
        if secondsAgo < twoSeconds {
            formattedString = "\(secondsAgo)\(secondString)"
        } else if secondsAgo < minute {
            formattedString = "\(secondsAgo)\(secondsString)"
        } else if secondsAgo < twoMinutes {
            formattedString = "\(secondsAgo / minute)\(minuteString)"
        } else if secondsAgo < hour {
            formattedString = "\(secondsAgo / minute)\(minutesString)"
        } else if secondsAgo < twoHours {
            formattedString = "\(secondsAgo / hour)\(hourString)"
        } else if secondsAgo < day {
            formattedString = "\(secondsAgo / hour)\(hoursString)"
        } else if secondsAgo < twoDays {
            formattedString = "\(secondsAgo / day)\(dayString)"
        } else if secondsAgo < week {
            formattedString = "\(secondsAgo / day)\(daysString)"
        } else if secondsAgo < twoWeeks {
            formattedString = "\(secondsAgo / week)\(weekString)"
        } else if secondsAgo < month {
            formattedString = "\(secondsAgo / week)\(weeksString)"
        } else if secondsAgo < twoMonths {
            formattedString = "\(secondsAgo / month)\(monthString)"
        } else if secondsAgo < year {
            formattedString = "\(secondsAgo / month)\(monthsString)"
        } else if secondsAgo < twoYears {
            formattedString = "\(secondsAgo / year)\(yearString)"
        } else {
            formattedString = "\(secondsAgo / year)\(yearsString)"
        }
        return formattedString
    }
    
    @objc private func setTheme() {
        
        let theme = CourierInboxTheme(
            newMessageAnimationStyle: .none,
            indicatorColor: .systemPink,
            titleFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 20),
                color: .red
            ),
            timeFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 10),
                color: .green
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Arial", size: 14)!,
                color: .blue
            ),
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
