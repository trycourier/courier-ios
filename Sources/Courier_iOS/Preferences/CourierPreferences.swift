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
    
    // MARK: Channels
    
    private let availableChannels: [CourierUserPreferencesChannel]
    
    // MARK: Data
    
    private(set) var topics: [CourierUserPreferencesTopic] = []
    
    // MARK: UI
    
    @objc public let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let courierBar = CourierBar()
    
    public init(
        availableChannels: [CourierUserPreferencesChannel] = CourierUserPreferencesChannel.allCases
    ) {
        
        self.availableChannels = availableChannels
        
        if (availableChannels.isEmpty) {
            fatalError("Must pass at least 1 channel to the CourierPreferences initializer.")
        }
        
        super.init(frame: .zero)
        setup()
        
    }
    
    override init(frame: CGRect) {
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.availableChannels = CourierUserPreferencesChannel.allCases
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
    
    @objc private func onRefresh() {
        refresh()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceTopicCell.id, for: indexPath) as! CourierPreferenceTopicCell

        let topic = topics[indexPath.row]
        cell.configureCell(topic: topic)

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
        
        // Build the sheet
        let sheetViewController = PreferencesSheetViewController(
            topic: topic,
            items: [
                CourierSheetItem(
                    title: "Topic", 
                    isOn: true,
                    isDisabled: false
                )
            ],
            onDismiss: { items in
                print(items)
            }
        )
        
        // Present the sheet
        parentViewController.present(sheetViewController, animated: true, completion: nil)
        
    }
    
    // Called when the view controller sheet is closed
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        // Get the view controller
        let viewController = presentationController.presentedViewController as? PreferencesSheetViewController
        
        // Get the topic of the view controller
        if let topic = viewController?.topic {
            savePreferences(newTopic: topic)
        }
        
    }
    
    private func savePreferences(newTopic: CourierUserPreferencesTopic) {
        
        Courier.shared.putUserPreferencesTopic(
            topicId: newTopic.topicId,
            status: newTopic.status,
            hasCustomRouting: newTopic.hasCustomRouting,
            customRouting: newTopic.customRouting,
            onSuccess: {
                print("YAY")
            },
            onFailure: { error in
                print(error)
            }
        )
        
    }
    
    private func getSheetHeight(sheet: CourierPreferencesSheet) -> CGFloat {
        
        let margins = CourierPreferencesSheet.marginTop + CourierPreferencesSheet.marginBottom
        
        let navBarHeight = sheet.navigationBar.frame.height == 0 ? 56 : sheet.navigationBar.frame.height
        
        let itemHeight: CGFloat = CGFloat(64 * availableChannels.count)
        
        return margins + navBarHeight + itemHeight
        
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
