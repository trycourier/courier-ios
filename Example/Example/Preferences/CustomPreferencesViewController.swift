//
//  CustomPreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 3/11/24.
//

import UIKit
import Courier_iOS

class CustomPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    private var topics: [CourierUserPreferencesTopic] = []
    
    enum State {
        case loading
        case error
        case content
        case empty
    }
    
    private let navController: UINavigationController
    
    init(navController: UINavigationController) {
        self.navController = navController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.navController = UINavigationController()
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

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

        view.addSubview(stateLabel)
        
        NSLayoutConstraint.activate([
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        setState(.loading)
        
        onRefresh()
        
    }
    
    @objc private func onRefresh() {
        Task {
            let prefs = try await Courier.shared.getUserPreferences()
            self.topics = prefs.items
            self.setState(self.topics.isEmpty ? .empty : .content)
            self.tableView.reloadData()
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
            self.stateLabel.text = "No topics found"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as! CustomTableViewCell
        let topic = self.topics[indexPath.row]
        cell.label.text = topic.toJson()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // Open the view controller
        let topic = self.topics[indexPath.row]
        let viewController = UpdatePreferencesViewController(topicId: topic.topicId)
        self.navController.pushViewController(viewController, animated: true)
        
    }

}
