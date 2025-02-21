//
//  PushViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier_iOS

class PushViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    @IBAction func refreshAction(_ sender: Any) {
        refresh()
    }
    
    @IBAction func requestPermissionsButton(_ sender: Any) {
        Task {
            let _ = try await Courier.requestNotificationPermission()
            refresh()
        }
    }
    
    var tokens = [("APNS Token", "Empty"), ("FCM Token", "Empty")]
    
    @objc func refresh() {
        
        Task {
            
            tokens[0].1 = await Courier.shared.getToken(for: .apn) ?? "Empty"
            tokens[1].1 = await Courier.shared.getToken(for: .firebaseFcm) ?? "Empty"
            
            tableView.reloadData()
            
            refreshControl.endRefreshing()
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Push"
        
        tableView.register(MonoListItem.self, forCellReuseIdentifier: MonoListItem.id)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonoListItem.id, for: indexPath) as! MonoListItem
        
        let item = tokens[indexPath.row]
        cell.configureCell(title: item.0, value: item.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let token = tokens[indexPath.row]
        UIPasteboard.general.string = token.1
        showCodeAlert(title: "\(token.0) Copied", code: token.1)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

