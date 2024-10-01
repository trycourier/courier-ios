//
//  UpdatePreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/11/24.
//

import UIKit
import Courier_iOS

import UIKit
import Courier_iOS

class UpdatePreferencesViewController: UIViewController {

    private let topicId: String
    private var tableView: UITableView!
    private var isLoading: Bool = true {
        didSet {
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            tableView.reloadData()
        }
    }
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        return indicator
    }()
    
    let statusValues: [CourierUserPreferencesStatus] = [
        .optedIn,
        .optedOut,
        .required
    ]
    
    private var topic: CourierUserPreferencesTopic? = nil
    
    init(topicId: String) {
        self.topicId = topicId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.topicId = "unknown"
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        self.title = self.topicId
        
        // Initialize and configure the table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        // Constraints for the table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Register cells
        tableView.register(SegmentedControlTableViewCell.self, forCellReuseIdentifier: "SegmentedControlCell")
        tableView.register(ToggleCell.self, forCellReuseIdentifier: "ToggleCell")
        
        // Add save button
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        refresh()
        
    }
    
    private func refresh() {
        
        Task {
            
            self.isLoading = true
            
            do {
                self.topic = try await Courier.shared.client?.preferences.getUserPreferenceTopic(topicId: self.topicId)
            } catch {
                showCodeAlert(title: "Error", code: CourierError(from: error).message)
            }
            
            self.isLoading = false
            
        }
        
    }
    
    @objc private func saveButtonTapped() {
        
        var segmentedControlValue: CourierUserPreferencesStatus?
        var hasCustomRouting: Bool?
        var selectedChannels: [CourierUserPreferencesChannel] = []

        // Loop through visible cells to collect values
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            switch indexPath.section {
            case 0:
                let cell = tableView.cellForRow(at: indexPath) as? SegmentedControlTableViewCell
                if let selectedIndex = cell?.segmentedControl.selectedSegmentIndex,
                   selectedIndex >= 0 && selectedIndex < statusValues.count {
                    segmentedControlValue = statusValues[selectedIndex]
                }
            case 1:
                let cell = tableView.cellForRow(at: indexPath) as? ToggleCell
                hasCustomRouting = cell?.switchControl.isOn
            case 2:
                let cell = tableView.cellForRow(at: indexPath) as? ToggleCell
                if let channelTitle = cell?.titleLabel.text,
                   let switchState = cell?.switchControl.isOn,
                   switchState {
                    if let channel = CourierUserPreferencesChannel(rawValue: channelTitle) {
                        selectedChannels.append(channel)
                    }
                }
            default:
                break
            }
        }
        
        Task {
            
            isLoading = true
            
            do {
                
                try await Courier.shared.client?.preferences.putUserPreferenceTopic(
                    topicId: topicId,
                    status: segmentedControlValue ?? .optedIn,
                    hasCustomRouting: hasCustomRouting ?? false,
                    customRouting: selectedChannels
                )
                
                navigationController?.popViewController(animated: true)
                
            } catch {
                
                showCodeAlert(title: "Update Error", code: CourierError(from: error).message)
                
            }
            
            isLoading = false
            
        }
        
    }

    
}

extension UpdatePreferencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 0 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // Segmented control
        case 1:
            return 1 // Toggle
        case 2:
            return CourierUserPreferencesChannel.allCases.count // Channels
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedControlCell", for: indexPath) as! SegmentedControlTableViewCell
            cell.segmentedControl.removeAllSegments()
            for (index, status) in statusValues.enumerated() {
                cell.segmentedControl.insertSegment(withTitle: status.rawValue, at: index, animated: false)
            }
            let index = statusValues.firstIndex(where: { $0 == self.topic?.status ?? self.topic?.defaultStatus ?? .optedIn })
            cell.segmentedControl.selectedSegmentIndex = index ?? 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleCell
            cell.titleLabel.text = "Use Custom Routing"
            cell.switchControl.isOn = self.topic?.hasCustomRouting ?? false
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleCell
            let channel = CourierUserPreferencesChannel.allCases[indexPath.row]
            cell.titleLabel.text = channel.rawValue
            cell.switchControl.isOn = self.topic?.customRouting.contains(channel) ?? false
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        switch section {
        case 0:
            headerLabel.text = "Status"
        case 1:
            headerLabel.text = "Use Custom Routing"
        case 2:
            headerLabel.text = "Routing Channels"
        default:
            headerLabel.text = nil
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class SegmentedControlTableViewCell: UITableViewCell {
    
    var segmentedControl: UISegmentedControl!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

class ToggleCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var switchControl: UISwitch!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Title Label
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Switch Control
        switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
}
