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
    private let onSheetDismiss: () -> Void
    
    init(title: String, channels: [CourierUserPreferencesChannel], onSheetDismiss: @escaping () -> Void) {
        self.title = title
        self.channels = channels
        self.onSheetDismiss = onSheetDismiss
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.title = "Topic Title"
        self.channels = CourierUserPreferencesChannel.allCases
        self.onSheetDismiss = {}
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.title = "Topic Title"
        self.channels = CourierUserPreferencesChannel.allCases
        self.onSheetDismiss = {}
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
        onSheetDismiss()
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
        return CourierUserPreferencesChannel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceChannelCell.id, for: indexPath) as! CourierPreferenceChannelCell

        let channel = CourierUserPreferencesChannel.allCases[indexPath.row]
        cell.configureCell(channel: channel)

        return cell
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
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configureCell(channel: CourierUserPreferencesChannel) {
        itemLabel.text = channel.rawValue
    }
    
}
