//
//  CourierPreferenceSheet.swift
//
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

internal struct CourierSheetItem {
    let title: String
    var isOn: Bool
    let isDisabled: Bool
}

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
    private var items: [CourierSheetItem]
    private let onSheetClose: () -> Void
    
    init(title: String, items: [CourierSheetItem], onSheetClose: @escaping () -> Void) {
        self.title = title
        self.items = items
        self.onSheetClose = onSheetClose
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.title = "Title"
        self.items = []
        self.onSheetClose = {}
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.title = "Title"
        self.items = []
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
        tableView.register(CourierPreferenceCell.self, forCellReuseIdentifier: CourierPreferenceCell.id)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CourierPreferencesSheet.marginBottom),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceCell.id, for: indexPath) as! CourierPreferenceCell
        
        var item = self.items[indexPath.row]

        cell.configureCell(
            item: item,
            onToggle: { isOn in
                
                // Update the item at index
                item.isOn = isOn
                self.items[indexPath.row] = item
                
            }
        )

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle the cell
        if let cell = tableView.cellForRow(at: indexPath) as? CourierPreferenceCell {
            cell.toggle()
        }
        
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CourierPreferencesSheet.cellHeight
    }
    
}
