//
//  AuthViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/1/23.
//

import UIKit
import Courier_iOS
import ShowTime

enum CourierEnvironment: String, CaseIterable {
    case production = "Production"
    case productionEU = "Production EU"
    case staging = "Staging"
    case dev = "Dev"
    case custom = "Custom"
    
    var urls: CourierClient.ApiUrls? {
        switch self {
        case .production:
            return .us
        case .productionEU:
            return .eu
        case .staging:
            return CourierClient.ApiUrls(
                rest: "https://api.staging-trycourier.com",
                graphql: "https://yubmnstah4.execute-api.us-east-1.amazonaws.com/staging/client/q",
                inboxGraphql: "https://4rq7n8hhjd.execute-api.us-east-1.amazonaws.com/staging/q",
                inboxWebSocket: "http://inbox-staging-ws-alb-490231599.us-east-1.elb.amazonaws.com"
            )
        case .dev:
            return CourierClient.ApiUrls(
                rest: "https://api.courierdev.com",
                graphql: "https://api.courierdev.com/client/q",
                inboxGraphql: "https://inbox.courierdev.com/q",
                inboxWebSocket: "wss://9mrugsdnk1.execute-api.us-east-1.amazonaws.com/dev"
            )
        case .custom:
            return nil
        }
    }
}

class AuthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var selectedEnvironment: CourierEnvironment = .production
    
    private lazy var options: [(String, String)] = {
        let userManager = UserManager.shared
        let credentials = userManager.getCredentials()
        
        let envName = credentials["environment"] ?? CourierEnvironment.production.rawValue
        selectedEnvironment = CourierEnvironment(rawValue: envName) ?? .production
        
        return [
            ("Environment", selectedEnvironment.rawValue),
            ("User ID", credentials["userId"] ?? ""),
            ("Tenant ID (Optional)", credentials["tenantId"] ?? ""),
            ("API Key", credentials["apiKey"] ?? Env.COURIER_AUTH_KEY),
            ("REST URL", credentials["restUrl"] ?? ""),
            ("GraphQL URL", credentials["graphqlUrl"] ?? ""),
            ("Inbox GraphQL URL", credentials["inboxGraphqlUrl"] ?? ""),
            ("Inbox WebSocket", credentials["inboxWebsocketUrl"] ?? "")
        ]
    }()
    
    private var authListener: CourierAuthenticationListener? = nil
    
    @IBOutlet weak var tableView: UITableView!
    private var toggleTouchesButton: UIBarButtonItem!
    private var saveButton: UIBarButtonItem!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    @objc private func saveButtonAction(_ sender: Any) {
        Task {
            await performSave()
        }
    }
    
    private func setSaving(_ isSaving: Bool) {
        if isSaving {
            saveButton.isEnabled = false
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: activityIndicator)
            ]
        } else {
            activityIndicator.stopAnimating()
            saveButton.isEnabled = !options[1].1.isEmpty
            navigationItem.rightBarButtonItems = [saveButton]
        }
    }
    
    private func performSave() async {
        setSaving(true)
        
        if await Courier.shared.userId != nil {
            await Courier.shared.signOut()
        }
        
        await performSignIn()
        
        setSaving(false)
    }
    
    @objc private func touchesButtonAction(_ sender: Any) {
        ShowTime.enabled = ShowTime.enabled == .always ? .never : .always
        updateShowTouchesLabel()
    }
    
    private func updateShowTouchesLabel() {
        let showTouches = ShowTime.enabled == .always
        toggleTouchesButton.title = showTouches ? "Hide Touches" : "Show Touches"
    }
    
    private func performSignIn() async {
        
        let userId = options[1].1
        let tenantId = options[2].1.isEmpty ? nil : options[2].1
        let apiKey = options[3].1
        
        if userId.isEmpty {
            await Courier.shared.signOut()
            return
        }
        
        do {
            let jwt = try await ExampleServer().generateJwt(
                baseUrl: options[4].1,
                authKey: apiKey,
                userId: userId
            )
            
            await Courier.shared.signIn(
                userId: userId,
                tenantId: tenantId,
                accessToken: jwt,
                apiUrls: CourierClient.ApiUrls(
                    rest: options[4].1,
                    graphql: options[5].1,
                    inboxGraphql: options[6].1,
                    inboxWebSocket: options[7].1
                )
            )
        } catch {
            await Courier.shared.signOut()
            showCodeAlert(title: "Error", code: "\(error)")
        }
    }
    
    private func applyEnvironment(_ env: CourierEnvironment) {
        selectedEnvironment = env
        options[0].1 = env.rawValue
        
        let userManager = UserManager.shared
        userManager.setCredential(key: "environment", value: env.rawValue)
        
        if let urls = env.urls {
            options[4].1 = urls.rest
            options[5].1 = urls.graphql
            options[6].1 = urls.inboxGraphql
            options[7].1 = urls.inboxWebSocket
            
            userManager.setCredential(key: "restUrl", value: urls.rest)
            userManager.setCredential(key: "graphqlUrl", value: urls.graphql)
            userManager.setCredential(key: "inboxGraphqlUrl", value: urls.inboxGraphql)
            userManager.setCredential(key: "inboxWebsocketUrl", value: urls.inboxWebSocket)
        }
        
        tableView.reloadData()
    }
    
    private func showEnvironmentPicker(from cell: UITableViewCell) {
        let alert = UIAlertController(
            title: "Select Environment",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for env in CourierEnvironment.allCases {
            let action = UIAlertAction(title: env.rawValue, style: .default) { [weak self] _ in
                self?.applyEnvironment(env)
            }
            if env == selectedEnvironment {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func showEditAlert(for row: Int) {
        let item = options[row]
        
        let alert = UIAlertController(title: item.0, message: nil, preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = item.0
            field.text = item.1
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.clearButtonMode = .always
        }
        
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            let value = alert.textFields?.first?.text ?? ""
            if !value.isEmpty {
                UIPasteboard.general.string = value
                self?.showCopiedToast()
            }
        })
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [self] _ in
            let value = alert.textFields?.first?.text ?? ""
            applyEdit(row: row, value: value)
        }
        
        alert.addAction(updateAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.preferredAction = updateAction
        
        present(alert, animated: true)
    }
    
    private func applyEdit(row: Int, value: String) {
        options[row].1 = value
        
        if row == 1 {
            saveButton.isEnabled = !value.isEmpty
        }
        
        let userManager = UserManager.shared
        switch row {
        case 1: userManager.setCredential(key: "userId", value: value)
        case 2: userManager.setCredential(key: "tenantId", value: value)
        case 3: userManager.setCredential(key: "apiKey", value: value)
        case 4: userManager.setCredential(key: "restUrl", value: value)
        case 5: userManager.setCredential(key: "graphqlUrl", value: value)
        case 6: userManager.setCredential(key: "inboxGraphqlUrl", value: value)
        case 7: userManager.setCredential(key: "inboxWebsocketUrl", value: value)
        default: break
        }
        
        if row >= 4 && selectedEnvironment != .custom {
            selectedEnvironment = .custom
            options[0].1 = CourierEnvironment.custom.rawValue
            userManager.setCredential(key: "environment", value: CourierEnvironment.custom.rawValue)
        }
        
        tableView.reloadData()
    }
    
    private func copyUrlToPasteboard(_ url: String, cell: UITableViewCell) {
        UIPasteboard.general.string = url
        showCopiedToast()
    }
    
    private func showCopiedToast() {
        let toastLabel = UILabel()
        toastLabel.text = "Copied to clipboard"
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toastLabel.heightAnchor.constraint(equalToConstant: 40),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        UIView.animate(withDuration: 0.2, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.2, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        
        toggleTouchesButton = UIBarButtonItem(
            title: "Show Touches",
            style: .plain,
            target: self,
            action: #selector(touchesButtonAction)
        )
        
        navigationItem.leftBarButtonItem = toggleTouchesButton
        
        ShowTime.enabled = .never
        updateShowTouchesLabel()
        
        saveButton = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveButtonAction)
        )
        
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItems = [saveButton]
        
        tableView.register(MonoListItem.self, forCellReuseIdentifier: MonoListItem.id)
        tableView.delegate = self
        tableView.dataSource = self
        
        saveButton.isEnabled = !options[1].1.isEmpty
        
        Task {
            authListener = await Courier.shared.addAuthenticationListener { [weak self] _ in
                Task {
                    self?.saveButton.isEnabled = !(self?.options[1].1.isEmpty ?? true)
                    self?.tableView.reloadData()
                }
            }
            
            if await Courier.shared.userId != nil {
                await performSave()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonoListItem.id, for: indexPath) as! MonoListItem
        
        let item = options[indexPath.row]
        let value = item.1.isEmpty ? "NOT SET" : item.1
        cell.configureCell(title: item.0, value: value)
        
        if indexPath.row == 0 {
            let editImage = UIImageView(image: UIImage(systemName: "pencil"))
            editImage.tintColor = .secondaryLabel
            editImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            cell.accessoryView = editImage
            cell.accessoryType = .none
        } else if indexPath.row >= 4 && selectedEnvironment != .custom {
            let copyImage = UIImageView(image: UIImage(systemName: "doc.on.doc"))
            copyImage.tintColor = .secondaryLabel
            copyImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            cell.accessoryView = copyImage
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .none
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) {
                showEnvironmentPicker(from: cell)
            }
            return
        }
        
        if indexPath.row >= 4 && selectedEnvironment != .custom {
            let url = options[indexPath.row].1
            if !url.isEmpty, let cell = tableView.cellForRow(at: indexPath) {
                copyUrlToPasteboard(url, cell: cell)
            }
            return
        }
        
        showEditAlert(for: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    deinit {
        authListener?.remove()
    }
}
