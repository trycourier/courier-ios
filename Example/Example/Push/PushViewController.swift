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
        
        tableView.register(TokenTableViewCell.self, forCellReuseIdentifier: TokenTableViewCell.id)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.id, for: indexPath) as! TokenTableViewCell
        
        let item = tokens[indexPath.row]
        cell.configureCell(title: item.0, item: item.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let token = tokens[indexPath.row]
        UIPasteboard.general.string = token.1
        showMessageAlert(title: "\(token.0) Copied", message: token.1)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

class TokenTableViewCell: UITableViewCell {
    
    static let id = "TokenTableViewCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(itemLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            titleLabel.widthAnchor.constraint(equalToConstant: 100), // Adjust the fixed width here
            
            itemLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureCell(title: String, item: String) {
        titleLabel.text = title
        itemLabel.text = item
    }
    
}

