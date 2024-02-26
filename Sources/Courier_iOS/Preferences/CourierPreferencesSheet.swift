//
//  CourierPreferenceSheet.swift
//
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

internal class CourierPreferencesSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    
    init() {
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
        addTableView()
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CourierPreferenceChannelCell.self, forCellReuseIdentifier: CourierPreferenceChannelCell.id)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configureCell(channel: CourierUserPreferencesChannel) {
        itemLabel.text = channel.rawValue
    }
    
}
