//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
@objc open class CourierPreferences: UIView, UITableViewDelegate, UITableViewDataSource, UISheetPresentationControllerDelegate {
    
    // MARK: Theme
    
    private let availableChannels: [CourierUserPreferencesChannel]
    
    private let lightTheme: CourierPreferencesTheme
    private let darkTheme: CourierPreferencesTheme
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierPreferencesTheme = .defaultLight
    
    // MARK: Data
    
    private(set) var topics: [CourierUserPreferencesTopic] = []
    
    // MARK: UI
    
    @objc public let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let courierBar = CourierBar()
    private var sheetViewController: PreferencesSheetViewController?
    
    public init(
        availableChannels: [CourierUserPreferencesChannel] = CourierUserPreferencesChannel.allCases,
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark
    ) {
        
        if (availableChannels.isEmpty) {
            fatalError("Must pass at least 1 channel to the CourierPreferences initializer.")
        }
        
        self.availableChannels = availableChannels
        
        // Theme
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        super.init(frame: .zero)
        setup()
        
    }
    
    override init(frame: CGRect) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
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
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierPreferenceTopicCell.self, forCellReuseIdentifier: CourierPreferenceTopicCell.id)

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
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
            reloadViews()
        }
        
    }
    
    private func setTheme(isDarkMode: Bool) {
        theme = isDarkMode ? darkTheme : lightTheme
    }
    
    private func reloadViews() {
        sheetViewController?.setTheme(theme: self.theme)
    }
    
    @objc private func onRefresh() {
        refresh()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceTopicCell.id, for: indexPath) as! CourierPreferenceTopicCell

        let topic = self.topics[indexPath.row]
        cell.configureCell(
            topic: topic, 
            availableChannels: self.availableChannels
        )

        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Present the sheet
        let topic = topics[indexPath.row]
        showSheet(topic: topic)
        
        // Deselect the cell
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
            fatalError("CourierPreferences must be added to a view hierarchy with a ViewController.")
        }
        
        var items = [CourierSheetItem]()
        
        items = CourierUserPreferencesChannel.allCases.map { channel in
            
            let isRequired = topic.status == .required
            
            var isOn = true
            
            if (topic.customRouting.isEmpty) {
                isOn = topic.status != .optedOut
            } else {
                isOn = topic.customRouting.contains { $0.rawValue == channel.rawValue }
            }
            
            return CourierSheetItem(
                title: channel.rawValue,
                isOn: isOn,
                isDisabled: isRequired,
                data: channel
            )
            
        }
        
        // Build the sheet
        sheetViewController = PreferencesSheetViewController(
            theme: theme,
            topic: topic,
            items: items,
            onDismiss: { items in
                
                // Unable to save. Settings required.
                if (topic.defaultStatus == .required && topic.status == .required) {
                    return
                }
                
                let selectedItems = items.filter { $0.isOn }.map { $0.data as! CourierUserPreferencesChannel }
                
                var newStatus: CourierUserPreferencesStatus = .unknown
                
                if (selectedItems.isEmpty) {
                    newStatus = .optedOut
                } else {
                    newStatus = .optedIn
                }
                
                var hasCustomRouting = false
                var customRouting = [CourierUserPreferencesChannel]()
                let areAllSelected = selectedItems.count == items.count
                
                if (areAllSelected && topic.defaultStatus == .optedIn) {
                    hasCustomRouting = false
                    customRouting = []
                } else if (selectedItems.isEmpty && topic.defaultStatus == .optedOut) {
                    hasCustomRouting = false
                    customRouting = []
                } else {
                    hasCustomRouting = true
                    customRouting = selectedItems
                }
                
                let newTopic = CourierUserPreferencesTopic(
                    defaultStatus: topic.defaultStatus.rawValue,
                    hasCustomRouting: hasCustomRouting,
                    customRouting: customRouting.map { $0.rawValue },
                    status: newStatus.rawValue,
                    topicId: topic.topicId,
                    topicName: topic.topicName
                )
                
                // Unchanged
                if (newTopic.isEqual(to: topic)) {
                    return
                }
                
                self.updateTopic(topicId: topic.topicId, newTopic: newTopic)
                
                // Update the Topic
                Courier.shared.putUserPreferencesTopic(
                    topicId: topic.topicId,
                    status: newStatus,
                    hasCustomRouting: hasCustomRouting,
                    customRouting: customRouting,
                    onSuccess: {
                        Courier.log("Topic updated: \(topic.topicId)")
                    },
                    onFailure: { error in
                        Courier.log(error.localizedDescription)
                        self.updateTopic(topicId: topic.topicId, newTopic: topic)
                    }
                )
                
                // Remove the sheet reference
                self.sheetViewController = nil
                
            }
        )
        
        // Present the sheet
        parentViewController.present(sheetViewController!, animated: true, completion: nil)
        
    }
    
    private func updateTopic(topicId: String, newTopic: CourierUserPreferencesTopic) {
            
        if let index = self.topics.firstIndex(where: { $0.topicId == topicId }) {
            
            // Update the topic
            self.topics[index] = newTopic
            
            // Run on main queue
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            }
            
        }
        
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
