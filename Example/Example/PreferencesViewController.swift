//
//  PreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 1/9/24.
//

import UIKit
import Courier_iOS

class PreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var topics: [CourierUserPreferencesTopic] = []
    
    private lazy var courierPreferences = {
        return CourierPreferences(
            lightTheme: CourierPreferencesTheme(
                sheetTitleFont: CourierStyles.Font(
                    font: UIFont(name: "Avenir Black", size: 20)!,
                    color: UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
                )
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"

//        tableView.register(TopicTableViewCell.self, forCellReuseIdentifier: TopicTableViewCell.id)
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        tableView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        
//        refresh()
        
        courierPreferences.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierPreferences)
        
        NSLayoutConstraint.activate([
            courierPreferences.topAnchor.constraint(equalTo: view.topAnchor),
            courierPreferences.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierPreferences.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierPreferences.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
    }
    
    @objc func refresh() {
        
        Task {
            
            refreshControl.beginRefreshing()
            
            let preferences = try await Courier.shared.getUserPreferences()
            topics = preferences.items
            
            tableView.reloadData()
            refreshControl.endRefreshing()
            
            
        }
        
    }
    
    func updateTopic(topicId: String) {
        
        Task {
            
            do {
                
                let topic = try await Courier.shared.getUserPreferencesTopic(
                    topicId: topicId
                )
                
                try await Courier.shared.putUserPreferencesTopic(
                    topicId: topic.topicId,
                    status: .optedIn,
                    hasCustomRouting: true,
                    customRouting: getRandomChannels()
                )
                
                refresh()
                
            } catch {
                
                showMessageAlert(
                    title: "Error Updating Preferences",
                    message: error.localizedDescription
                )
                
            }
            
        }
        
    }
    
    func getRandomChannels() -> [CourierUserPreferencesChannel] {
        
        let channelValues: [CourierUserPreferencesChannel] = [.directMessage, .email, .push, .sms, .webhook]
        
        let randomCount = Int.random(in: 0...channelValues.count)
        
        var randomChannels: [CourierUserPreferencesChannel] = []
        
        while randomChannels.count < randomCount {
            if let randomChannel = channelValues.randomElement(), !randomChannels.contains(randomChannel) {
                randomChannels.append(randomChannel)
            }
        }
        
        return randomChannels
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicTableViewCell.id, for: indexPath) as! TopicTableViewCell
        
        let topic = topics[indexPath.row]
        cell.configureCell(topic: topic)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = topics[indexPath.row]
        updateTopic(topicId: topic.topicId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}

class TopicTableViewCell: UITableViewCell {
    
    static let id = "TopicTableViewCell"
    
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
        contentView.addSubview(itemLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureCell(topic: CourierUserPreferencesTopic) {
        itemLabel.text = topic.convertToJSONString()
    }
    
}
