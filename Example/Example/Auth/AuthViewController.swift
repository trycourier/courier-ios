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
    
    private var options: [(String, String)] = [
        ("User ID", "Loading..."),
        ("Tenant ID", "Loading..."),
        ("REST URL", "Loading..."),
        ("GraphQL URL", "Loading..."),
        ("Inbox GraphQL URL", "Loading..."),
        ("Inbox WebSocket", "Loading...")
    ]
    
    private var canEditAuthentication = false
    
    private var authListener: CourierAuthenticationListener? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toggleTouchesButton: UIBarButtonItem!
    @IBAction func toggleTouchesButtonAction(_ sender: Any) {
        ShowTime.enabled = ShowTime.enabled == .always ? .never : .always
        updateShowTouchesLabel()
    }
    
    @IBOutlet weak var authButton: UIBarButtonItem!
    @IBAction func authButtonAction(_ sender: Any) {
        
        self.canEditAuthentication = false
        self.authButton.isEnabled = false
        self.tableView.reloadData()
        
        Task {
            
            if let _ = await Courier.shared.userId {
                
                await Courier.shared.signOut()
                
            } else {
                
                let userId = options[0].1
                let tenantId = options[1].1
                let rest = options[2].1
                let graphQL = options[3].1
                let inboxGraphQL = options[4].1
                let inboxWebsocket = options[5].1
                
                let jwt = try await ExampleServer().generateJwt(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: userId
                )
                
                await Courier.shared.signIn(
                    userId: userId,
                    tenantId: tenantId.isEmpty ? nil : tenantId,
                    accessToken: jwt,
                    baseUrls: CourierClient.ApiUrls(
                        rest: rest,
                        graphql: graphQL,
                        inboxGraphql: inboxGraphQL,
                        inboxWebSocket: inboxWebsocket
                    )
                )
                
            }
            
        }
    }
    
    private func updateShowTouchesLabel() {
        let showTouches = ShowTime.enabled == .always
        toggleTouchesButton.title = showTouches ? "Hide Touches" : "Show Touches"
    }
    
    private func updateUserState(_ courier: Courier) async {
        
        canEditAuthentication = await courier.userId == nil
        authButton.isEnabled = true
        authButton.title = await courier.userId == nil ? "Sign In" : "Sign Out"
        
        let defaultUrls = CourierClient.ApiUrls()
        
        options[0].1 = await courier.userId ?? ""
        options[1].1 = await courier.tenantId ?? ""
        options[2].1 = await courier.client?.options.apiUrls.rest ?? defaultUrls.rest
        options[3].1 = await courier.client?.options.apiUrls.graphql ?? defaultUrls.graphql
        options[4].1 = await courier.client?.options.apiUrls.inboxGraphql ?? defaultUrls.inboxGraphql
        options[5].1 = await courier.client?.options.apiUrls.inboxWebSocket ?? defaultUrls.inboxWebSocket
        
        authButton.isEnabled = !options[0].1.isEmpty
        
        tableView.reloadData()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        
        // Set touches
        ShowTime.enabled = .never
        updateShowTouchesLabel()
        
        // Build the tableview
        tableView.register(MonoListItem.self, forCellReuseIdentifier: MonoListItem.id)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Disable auth button on launch
        authButton.isEnabled = false
        
        Task {
            
            if await Courier.shared.isUserSignedIn {
                
                let jwt = try await ExampleServer().generateJwt(
                    authKey: Env.COURIER_AUTH_KEY,
                    userId: Courier.shared.userId!
                )
                
                await Courier.shared.signIn(
                    userId: Courier.shared.userId!,
                    tenantId: Courier.shared.tenantId,
                    accessToken: jwt
                )
                
            }
            
            await self.updateUserState(Courier.shared)
            
            authListener = await Courier.shared.addAuthenticationListener { [weak self] userId in
                Task {
                    await self?.updateUserState(Courier.shared)
                }
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
        cell.configureCell(title: item.0, value: value, canEdit: canEditAuthentication)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !canEditAuthentication {
            return
        }
        
        let item = options[indexPath.row]
        
        showInputAlert(title: item.0, inputs: [item.0], action: "Update") { [self] values in
            
            let value = values[0]
            options[indexPath.row].1 = value
            
            if indexPath.row == 0 {
                authButton.isEnabled = !value.isEmpty
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

