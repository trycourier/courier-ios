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
        ("API Key", "Loading..."),
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
                let apiKey = options[2].1
                let rest = options[3].1
                let graphQL = options[4].1
                let inboxGraphQL = options[5].1
                let inboxWebsocket = options[6].1
                
                // Set the usermanager values
                let userManager = UserManager.shared
                userManager.setCredential(key: "restUrl", value: rest)
                userManager.setCredential(key: "graphqlUrl", value: graphQL)
                userManager.setCredential(key: "inboxGraphqlUrl", value: inboxGraphQL)
                userManager.setCredential(key: "inboxWebsocketUrl", value: inboxWebsocket)
                
                do {
                    
                    // Get the new jwt
                    let jwt = try await ExampleServer().generateJwt(
                        authKey: apiKey,
                        userId: userId
                    )
                    
                    await signIn(
                        userId: userId,
                        tenantId: tenantId.isEmpty ? nil : tenantId,
                        accessToken: jwt
                    )
                    
                } catch {
                    
                    await Courier.shared.signOut()
                    await self.updateUserState(Courier.shared)
                    
                }
                
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
        
        let credentials = UserManager.shared.getCredentials()
        
        options[0].1 = await courier.userId ?? ""
        options[1].1 = await courier.tenantId ?? ""
        options[2].1 = credentials["apiKey"] ?? Env.COURIER_AUTH_KEY
        options[3].1 = await courier.client?.options.apiUrls.rest ?? credentials["restUrl"]!
        options[4].1 = await courier.client?.options.apiUrls.graphql ?? credentials["graphqlUrl"]!
        options[5].1 = await courier.client?.options.apiUrls.inboxGraphql ?? credentials["inboxGraphqlUrl"]!
        options[6].1 = await courier.client?.options.apiUrls.inboxWebSocket ?? credentials["inboxWebsocketUrl"]!
        
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
                
                do {
                    
                    let jwt = try await ExampleServer().generateJwt(
                        authKey: UserManager.shared.getCredential(forKey: "apiKey") ?? Env.COURIER_AUTH_KEY,
                        userId: Courier.shared.userId!
                    )
                    
                    await signIn(
                        userId: Courier.shared.userId!,
                        tenantId: Courier.shared.tenantId,
                        accessToken: jwt
                    )
                    
                } catch {
                    
                    await Courier.shared.signOut()
                    await self.updateUserState(Courier.shared)
                    
                }
                
            }
            
            await self.updateUserState(Courier.shared)
            
            authListener = await Courier.shared.addAuthenticationListener { [weak self] userId in
                Task {
                    await self?.updateUserState(Courier.shared)
                }
            }
            
        }
        
    }
    
    private func signIn(userId: String, tenantId: String?, accessToken: String) async {
        let userManager = UserManager.shared
        await Courier.shared.signIn(
            userId: userId,
            tenantId: tenantId,
            accessToken: accessToken,
            baseUrls: CourierClient.ApiUrls(
                rest: userManager.getCredential(forKey: "restUrl")!,
                graphql: userManager.getCredential(forKey: "graphqlUrl")!,
                inboxGraphql: userManager.getCredential(forKey: "inboxGraphqlUrl")!,
                inboxWebSocket: userManager.getCredential(forKey: "inboxWebsocketUrl")!
            )
        )
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
        
        showInputAlert(title: item.0, inputs: [(item.0, item.1)], action: "Update") { [self] values in
            
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

