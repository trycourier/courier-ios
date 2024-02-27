//
//  CourierPreferenceSheet.swift
//
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

internal class CourierPreferencesSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    static let marginTop: CGFloat = 10
    static let marginBottom: CGFloat = 16
    static let cellHeight: CGFloat = 64
    
    private let tableView = UITableView()
    
    lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        return navBar
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let title: String
    private let channels: [CourierUserPreferencesChannel]
    private let viewController: PreferencesSheetViewController
    private let onSheetClose: () -> Void
    private let topic: CourierUserPreferencesTopic
    
    init(title: String, channels: [CourierUserPreferencesChannel], topic: CourierUserPreferencesTopic, viewController: PreferencesSheetViewController, onSheetClose: @escaping () -> Void) {
        self.title = title
        self.channels = channels
        self.topic = topic
        self.viewController = viewController
        self.onSheetClose = onSheetClose
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.title = "Topic Title"
        self.channels = CourierUserPreferencesChannel.allCases
        self.topic = CourierUserPreferencesTopic(
            defaultStatus: "",
            hasCustomRouting: false,
            customRouting: [],
            status: "",
            topicId: "",
            topicName: ""
        )
        self.viewController = PreferencesSheetViewController()
        self.onSheetClose = {}
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.title = "Topic Title"
        self.channels = CourierUserPreferencesChannel.allCases
        self.topic = CourierUserPreferencesTopic(
            defaultStatus: "",
            hasCustomRouting: false,
            customRouting: [],
            status: "",
            topicId: "",
            topicName: ""
        )
        self.viewController = PreferencesSheetViewController()
        self.onSheetClose = {}
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addTitleBar()
        addTableView()
    }
    
    private func addTitleBar() {
        
        addSubview(navigationBar)
        
        let navItem = UINavigationItem(title: title)
        let rightButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonClick))
        navItem.rightBarButtonItem = rightButtonItem
        navigationBar.items = [navItem]
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor, constant: CourierPreferencesSheet.marginTop),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    @objc private func closeButtonClick() {
        onSheetClose()
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierPreferenceChannelCell.self, forCellReuseIdentifier: CourierPreferenceChannelCell.id)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CourierPreferencesSheet.marginBottom),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceChannelCell.id, for: indexPath) as! CourierPreferenceChannelCell
        
        let channel = self.channels[indexPath.row]

        cell.configureCell(
            channel: channel,
            topic: self.topic,
            onToggle: { isOn in
                
                // Get the current topic from the viewController
                guard var currentTopic = self.viewController.topic else {
                    return
                }

                // Update the current topic based on the value of isOn
                currentTopic = isOn ? currentTopic.addCustomChannel(channel: channel) : currentTopic.removeCustomChannel(channel: channel)

                // Assign the updated topic back to the viewController
                self.viewController.topic = currentTopic
                
            }
        )

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle the cell
        if let cell = tableView.cellForRow(at: indexPath) as? CourierPreferenceChannelCell {
            cell.toggle()
        }
        
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CourierPreferencesSheet.cellHeight
    }
    
}

internal class CourierPreferenceChannelCell: UITableViewCell {
    
    static let id = "CourierPreferenceChannelCell"
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private var onToggle: ((Bool) -> Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        toggleSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(itemLabel)
        contentView.addSubview(toggleSwitch)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell(channel: CourierUserPreferencesChannel, topic: CourierUserPreferencesTopic, onToggle: @escaping (Bool) -> Void) {
        
        self.itemLabel.text = channel.rawValue
        self.onToggle = onToggle
        
        // If required, users cannot change this
        if (topic.status == .required) {
            toggleSwitch.isOn = true
            toggleSwitch.isEnabled = false
            toggleSwitch.isUserInteractionEnabled = false
            return
        }
        
        // If opted out, disable all toggles
        if (topic.status == .optedOut) {
            toggleSwitch.isOn = false
            return
        }
        
        // Enable all as the fallback
        if (topic.customRouting.isEmpty) {
            toggleSwitch.isOn = true
            return
        }
        
        // Apply custom settings
        let isToggled = topic.customRouting.contains { $0.rawValue == channel.rawValue }
        toggleSwitch.isOn = isToggled
        
    }
    
    internal func toggle() {
        toggleSwitch.setOn(!toggleSwitch.isOn, animated: true)
        switchToggled(toggleSwitch)
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}
