//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
@objc open class CourierPreferences: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @objc public let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let courierBar = CourierBar()
    
    var topics: [CourierUserPreferencesTopic] = []
    
    @objc public init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
//        addCourierBar()
        addTableView()
        
        refresh()
        
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
    
    // TODO: This
    private func addCourierBar() {
        
        addSubview(courierBar)
        
        NSLayoutConstraint.activate([
            courierBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addTableView() {
        
        tableView.backgroundColor = .green
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourierTopicTableViewCell.self, forCellReuseIdentifier: CourierTopicTableViewCell.id)

        // Add the refresh control
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    @objc private func onRefresh() {
        refreshControl.endRefreshing()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierTopicTableViewCell.id, for: indexPath) as! CourierTopicTableViewCell

        let topic = topics[indexPath.row]
        cell.configureCell(topic: topic)

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = topics[indexPath.row]
        showSheet(topic: topic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func showSheet(topic: CourierUserPreferencesTopic) {
        
        guard let parentViewController = parentViewController else {
            fatalError("CourierPreferences must be added to a view hierarchy with a view controller.")
        }
        
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "This is a sheet"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentVC.view.addSubview(label) // HERE
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentVC.view.centerYAnchor)
        ])
        
        let sheetPresentationController = contentVC.sheetPresentationController
        sheetPresentationController?.detents = [.medium(), .large()]
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.preferredCornerRadius = 16
        
        parentViewController.present(contentVC, animated: true, completion: nil)
        
    }
    
}

internal class CourierTopicTableViewCell: UITableViewCell {
    
    static let id = "CourierTopicTableViewCell"
    
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

extension CourierUserPreferencesTopic {
    
    @objc func convertToJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting to JSON: \(error.localizedDescription)")
        }
        return nil
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
}
