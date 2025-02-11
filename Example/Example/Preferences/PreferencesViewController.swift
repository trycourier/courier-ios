//
//  PreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 1/9/24.
//

import UIKit
import Courier_iOS
import SwiftUI

class PreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private static let listItemId = "preferences_preview_cell"

    var tableView: UITableView!
    
    private lazy var swiftUIViewController: UIHostingController<SwiftUIPreferencesViewController> = {
        let swiftUIView = SwiftUIPreferencesViewController()
        let hostingController = UIHostingController(rootView: swiftUIView)
        return hostingController
    }()

    private lazy var preferences: [(String, () -> UIViewController)] = [
        ("Default", { PrebuiltPreferencesViewController() }),
        ("Default (Topic Mode)", { PrebuiltPreferencesViewController(mode: .topic) }),
        ("Branded", { BrandedPreferencesViewController() }),
        ("Styled", { StyledPreferencesViewController() }),
        ("Custom (UIKit)", { CustomPreferencesViewController() }),
        ("Custom (SwiftUI)", { self.swiftUIViewController }),
        ("Raw JSON", { RawPreferencesViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preferences"
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PreferencesViewController.listItemId)
        
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesViewController.listItemId, for: indexPath)
        cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.text = preferences[indexPath.row].0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get the page
        let page = preferences[indexPath.row]
        
        // Create the view controller
        let viewController = page.1()
        viewController.title = page.0
        viewController.view.backgroundColor = .systemBackground
        
        // Push the view controller and deselect
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
