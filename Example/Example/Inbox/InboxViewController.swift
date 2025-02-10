import UIKit
import SwiftUI
import Courier_iOS

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private static let listItemId = "inbox_preview_cell"

    var tableView: UITableView!
    
    private lazy var swiftUIViewController: UIHostingController<SwiftUIViewController> = {
        let swiftUIView = SwiftUIViewController()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.title = "SwiftUI Inbox"
        return hostingController
    }()

    private lazy var inboxes: [(String, () -> UIViewController)] = [
        ("Default", { PrebuiltInboxViewController() }),
        ("Branded", { BrandedInboxViewController() }),
        ("Styled", { StyledInboxViewController() }),
        ("Custom (UIKit)", { CustomInboxViewController() }),
        ("Custom (SwiftUI)", { self.swiftUIViewController }),
        ("Raw JSON", { RawInboxViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Inboxes"
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: InboxViewController.listItemId)
        
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InboxViewController.listItemId, for: indexPath)
        cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.text = inboxes[indexPath.row].0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get the page
        let page = inboxes[indexPath.row]
        
        // Create the view controller
        let viewController = page.1()
        viewController.title = page.0
        viewController.view.backgroundColor = .systemBackground
        
        // Add the read all button
        let readAllButton = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAllClick))
        viewController.navigationItem.rightBarButtonItem = readAllButton
        
        // Push the view controller and deselect
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func readAllClick() {
        Task {
            do {
                try await Courier.shared.readAllInboxMessages()
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }
    
}
