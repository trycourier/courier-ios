//
//  AuthViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/1/23.
//

import UIKit
import Courier_iOS
import ShowTime

class AuthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var options: [(String, String)] = {
        let userManager = UserManager.shared
        let credentials = userManager.getCredentials()
        return [
            ("User ID", credentials["userId"] ?? ""),
            ("Tenant ID (Optional)", credentials["tenantId"] ?? ""),
            ("API Key", credentials["apiKey"] ?? Env.COURIER_AUTH_KEY),
            ("REST URL", credentials["restUrl"] ?? ""),
            ("GraphQL URL", credentials["graphqlUrl"] ?? ""),
            ("Inbox GraphQL URL", credentials["inboxGraphqlUrl"] ?? ""),
            ("Inbox WebSocket", credentials["inboxWebsocketUrl"] ?? "")
        ]
    }()
    
    private var canEditAuthentication = false
    private var authListener: CourierAuthenticationListener? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var authButton: UIBarButtonItem!
    private var toggleTouchesButton: UIBarButtonItem!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    @IBAction func resetButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(
            title: "Confirm Reset",
            message: "Are you sure you want to reset all the values?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { _ in
                Task {
                    // Sign out if currently signed in
                    if await Courier.shared.userId != nil {
                        await Courier.shared.signOut()
                    }
                    
                    self.resetUser()
                    
                    await self.updateUserState()
                }
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = resetButton
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func resetUser() {
        
        // Clear UserManager credentials
        let userManager = UserManager.shared
        userManager.removeCredentials()
        
        // Reset options to default values
        let credentials = userManager.getCredentials()
        self.options = [
            ("User ID", ""),
            ("Tenant ID (Optional)", ""),
            ("API Key", credentials["apiKey"] ?? Env.COURIER_AUTH_KEY),
            ("REST URL", credentials["restUrl"] ?? ""),
            ("GraphQL URL", credentials["graphqlUrl"] ?? ""),
            ("Inbox GraphQL URL", credentials["inboxGraphqlUrl"] ?? ""),
            ("Inbox WebSocket", credentials["inboxWebsocketUrl"] ?? "")
        ]
        
    }
    
    @IBAction func authButtonAction(_ sender: Any) {
        self.canEditAuthentication = false
        self.authButton.isEnabled = false
        self.tableView.reloadData()
        
        Task {
            if await Courier.shared.userId != nil {
                await Courier.shared.signOut()
            } else {
                await performSignIn()
            }
            await updateUserState()
        }
    }
    
    @objc private func touchesButtonAction(_ sender: Any) {
        ShowTime.enabled = ShowTime.enabled == .always ? .never : .always
        updateShowTouchesLabel()
    }
    
    private func updateShowTouchesLabel() {
        let showTouches = ShowTime.enabled == .always
        toggleTouchesButton.title = showTouches ? "Hide Touches" : "Show Touches"
    }
    
    private func updateUserState() async {
        canEditAuthentication = await Courier.shared.userId == nil
        authButton.isEnabled = true
        authButton.title = await Courier.shared.userId == nil ? "Sign In" : "Sign Out"
        authButton.isEnabled = !options[0].1.isEmpty
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    private func performSignIn() async {
        
        self.activityIndicator.startAnimating()
        
        let userId = options[0].1
        let tenantId = options[1].1.isEmpty ? nil : options[1].1
        let apiKey = options[2].1
        
        if userId.isEmpty {
            await Courier.shared.signOut()
            return
        }
        
        do {
            let jwt = try await ExampleServer().generateJwt(
                baseUrl: options[3].1,
                authKey: apiKey,
                userId: userId
            )
            
            await Courier.shared.signIn(
                userId: userId,
                tenantId: tenantId,
                accessToken: jwt,
                baseUrls: CourierClient.ApiUrls(
                    rest: options[3].1,
                    graphql: options[4].1,
                    inboxGraphql: options[5].1,
                    inboxWebSocket: options[6].1
                )
            )
        } catch {
            await Courier.shared.signOut()
            showCodeAlert(title: "Error", code: "\(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        
        // Create toolbar (action bar) with Reset button
        toggleTouchesButton = UIBarButtonItem(
            title: "Show Touches",
            style: .plain,
            target: self,
            action: #selector(touchesButtonAction)
        )
        
        // Move Show Touches to top left navigation bar
        navigationItem.leftBarButtonItem = toggleTouchesButton
        
        // Set touches initial state
        ShowTime.enabled = .never
        updateShowTouchesLabel()
        
        // Build the tableview
        tableView.register(MonoListItem.self, forCellReuseIdentifier: MonoListItem.id)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Disable auth button on launch
        authButton.isEnabled = false
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: activityIndicator)]
        
        Task {
            authListener = await Courier.shared.addAuthenticationListener { [weak self] _ in
                Task {
                    await self?.updateUserState()
                }
            }
            
            if await Courier.shared.userId != nil {
                await performSignIn()
            }
            
            await self.updateUserState()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonoListItem.id, for: indexPath) as! MonoListItem
        
        let item = options[indexPath.row]
        let value = item.1.isEmpty ? "NOT SET" : item.1
        cell.configureCell(title: item.0, value: value, canEdit: canEditAuthentication)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !canEditAuthentication { return }
        
        let item = options[indexPath.row]
        
        showInputAlert(title: item.0, inputs: [(item.0, item.1)], action: "Update") { [self] values in
            let value = values[0]
            options[indexPath.row].1 = value
            
            if indexPath.row == 0 {
                authButton.isEnabled = !value.isEmpty
            }
            
            // Update UserManager with new value
            let userManager = UserManager.shared
            switch indexPath.row {
            case 0: userManager.setCredential(key: "userId", value: value)
            case 1: userManager.setCredential(key: "tenantId", value: value)
            case 2: userManager.setCredential(key: "apiKey", value: value)
            case 3: userManager.setCredential(key: "restUrl", value: value)
            case 4: userManager.setCredential(key: "graphqlUrl", value: value)
            case 5: userManager.setCredential(key: "inboxGraphqlUrl", value: value)
            case 6: userManager.setCredential(key: "inboxWebsocketUrl", value: value)
            default: break
            }
            
            tableView.reloadData()
        }
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
