//
//  AuthViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/1/23.
//

import UIKit
import Courier_iOS
import ShowTime

struct CourierEnvironment: Equatable {
    let name: String
    let urls: CourierClient.ApiUrls?

    static let production = CourierEnvironment(name: "Production", urls: .us)
    static let productionEU = CourierEnvironment(name: "Production EU", urls: .eu)
    static let custom = CourierEnvironment(name: "Custom", urls: nil)

    // Only production hosts are committed, because this repo is public. Internal hosts come from
    // the gitignored Env.swift through `localEnvironments`, so a local build can still offer them.
    static var all: [CourierEnvironment] {
        [.production, .productionEU] + Env.localEnvironments + [.custom]
    }

    static func named(_ name: String) -> CourierEnvironment? {
        all.first { $0.name == name }
    }

    static func == (lhs: CourierEnvironment, rhs: CourierEnvironment) -> Bool {
        lhs.name == rhs.name
    }
}

/**
 Extra environments for local builds. Declare them in the gitignored Env.swift, and the
 environment picker lists them between Production EU and Custom:

 ```swift
 static let localEnvironments: [CourierEnvironment] = [
     CourierEnvironment(name: "My Environment", urls: CourierClient.ApiUrls(
         rest: "https://…", graphql: "https://…/client/q",
         inboxGraphql: "https://…/q", inboxWebSocket: "wss://…"
     ))
 ]
 ```

 Env.swift files that don't declare it, like the copy CI makes from EnvSample.swift, fall back to
 the empty default below and keep compiling.
 */
protocol LocalEnvironmentProviding {
    static var localEnvironments: [CourierEnvironment] { get }
}

extension LocalEnvironmentProviding {
    static var localEnvironments: [CourierEnvironment] { [] }
}

extension Env: LocalEnvironmentProviding {}

class AuthViewController: UIViewController, UICollectionViewDelegate {
    
    private enum Section: Int, CaseIterable {
        case session, user, environment, developer
        
        var title: String? {
            switch self {
            case .session: return nil
            case .user: return "User"
            case .environment: return "Environment"
            case .developer: return "Developer"
            }
        }
        
        var footer: String? {
            switch self {
            case .session: return nil
            case .user: return nil
            case .environment: return "Pick an environment, or edit a URL to use a custom one."
            case .developer: return "Draws touches on screen, for recordings."
            }
        }
    }
    
    private enum Item: Hashable {
        case status
        case signInButton
        case option(Int)
        case showTouches
    }
    
    private var selectedEnvironment: CourierEnvironment = .production
    
    private lazy var options: [(String, String)] = {
        let userManager = UserManager.shared
        let credentials = userManager.getCredentials()
        
        // A saved environment this build doesn't define (a local one, removed from Env.swift) keeps
        // its saved URLs, so it's labeled Custom rather than Production.
        let envName = credentials["environment"] ?? CourierEnvironment.production.name
        selectedEnvironment = CourierEnvironment.named(envName) ?? .custom
        
        return [
            ("Environment", selectedEnvironment.name),
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
    private var signedInUserId: String? = nil
    private var isWorking = false
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var isEditableUrl: Bool {
        return selectedEnvironment == .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auth"
        ShowTime.enabled = .never
        
        configureCollectionView()
        
        Task { [weak self] in
            let listener = await Courier.shared.addAuthenticationListener { [weak self] userId in
                self?.signedInUserId = userId
                self?.reloadItems()
            }
            self?.authListener = listener
            
            let userId = await Courier.shared.userId
            self?.signedInUserId = userId
            self?.reloadItems()
            
            // The example issues short-lived tokens, so get a fresh one on every launch
            if userId != nil {
                await self?.signIn()
            }
        }
    }
    
    // MARK: List
    
    private func configureCollectionView() {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = Section.allCases[sectionIndex]
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = section.title == nil ? .none : .supplementary
            configuration.footerMode = section.footer == nil ? .none : .supplementary
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [unowned self] cell, _, item in
            configure(cell, for: item)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { header, _, indexPath in
            var content = UIListContentConfiguration.header()
            content.text = Section.allCases[indexPath.section].title
            header.contentConfiguration = content
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) { footer, _, indexPath in
            var content = UIListContentConfiguration.footer()
            content.text = Section.allCases[indexPath.section].footer
            footer.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([.status, .signInButton], toSection: .session)
        snapshot.appendItems([.option(1), .option(2), .option(3)], toSection: .user)
        snapshot.appendItems([.option(0), .option(4), .option(5), .option(6), .option(7)], toSection: .environment)
        snapshot.appendItems([.showTouches], toSection: .developer)
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
    
    private func configure(_ cell: UICollectionViewListCell, for item: Item) {
        
        cell.accessibilityTraits = []
        
        switch item {
            
        case .status:
            var content = UIListContentConfiguration.subtitleCell()
            content.image = UIImage(systemName: signedInUserId == nil ? "person.crop.circle.badge.xmark" : "person.crop.circle.badge.checkmark")
            content.imageProperties.tintColor = signedInUserId == nil ? .secondaryLabel : .systemGreen
            content.text = signedInUserId == nil ? "Signed out" : "Signed in"
            content.secondaryText = signedInUserId ?? (options[1].1.isEmpty ? "Set a user ID, then sign in." : "Ready to sign in as \(options[1].1).")
            content.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = content
            cell.accessories = []
            
        case .signInButton:
            let isSignedIn = signedInUserId != nil
            var content = UIListContentConfiguration.cell()
            // A status label rather than a spinner, so the centered text doesn't shift while it works
            if isWorking {
                content.text = isSignedIn ? "Signing Out…" : "Signing In…"
            } else {
                content.text = isSignedIn ? "Sign Out" : "Sign In"
            }
            content.textProperties.alignment = .center
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.textProperties.color = isWorking ? .secondaryLabel : (isSignedIn ? .systemRed : .tintColor)
            cell.contentConfiguration = content
            cell.accessories = []
            cell.accessibilityTraits = .button
            // The device tests find these by ID
            cell.accessibilityIdentifier = isSignedIn ? "signOutButton" : "signInButton"
            
        case .option(let row):
            let (title, value) = options[row]
            if row == 0 {
                var content = UIListContentConfiguration.valueCell()
                content.text = title
                content.secondaryText = value
                cell.contentConfiguration = content
                cell.accessories = [.popUpMenu(environmentMenu())]
            } else {
                var content = UIListContentConfiguration.subtitleCell()
                content.text = title
                content.textProperties.font = .preferredFont(forTextStyle: .footnote)
                content.textProperties.color = .secondaryLabel
                content.secondaryText = value.isEmpty ? "Not set" : value
                content.secondaryTextProperties.font = value.isEmpty
                    ? .preferredFont(forTextStyle: .subheadline)
                    : .monospaced(.subheadline)
                // Wrap long keys and tokens by character, so no hyphen ends up in a value someone copies
                content.secondaryTextProperties.lineBreakMode = .byCharWrapping
                content.secondaryTextProperties.adjustsFontForContentSizeCategory = true
                content.secondaryTextProperties.color = value.isEmpty ? .tertiaryLabel : .label
                content.textToSecondaryTextVerticalPadding = 4
                cell.contentConfiguration = content
                cell.accessories = isEditable(row: row) ? [.disclosureIndicator()] : [.customView(configuration: .copyIndicator)]
            }
            
        case .showTouches:
            var content = UIListContentConfiguration.cell()
            content.text = "Show Touches"
            content.image = UIImage(systemName: "hand.tap")
            cell.contentConfiguration = content
            let toggle = UISwitch()
            toggle.isOn = ShowTime.enabled == .always
            toggle.addAction(UIAction { action in
                ShowTime.enabled = (action.sender as? UISwitch)?.isOn == true ? .always : .never
            }, for: .valueChanged)
            cell.accessories = [.customView(configuration: .init(customView: toggle, placement: .trailing()))]
            
        }
        
    }
    
    private func isEditable(row: Int) -> Bool {
        return row < 4 || isEditableUrl
    }
    
    private func reloadItems() {
        guard let dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func environmentMenu() -> UIMenu {
        return UIMenu(children: CourierEnvironment.all.map { env in
            UIAction(title: env.name, state: env == selectedEnvironment ? .on : .off) { [weak self] _ in
                self?.applyEnvironment(env)
            }
        })
    }
    
    // MARK: Selection
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .status, .showTouches: return false
        default: return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch dataSource.itemIdentifier(for: indexPath) {
        case .signInButton:
            guard !isWorking else { return }
            Task {
                signedInUserId == nil ? await signIn() : await signOut()
            }
        case .option(let row) where row > 0:
            if isEditable(row: row) {
                editOption(row: row)
            } else {
                copy(options[row])
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, case .option(let row) = dataSource.itemIdentifier(for: indexPath), row > 0 else { return nil }
        let option = options[row]
        guard !option.1.isEmpty else { return nil }
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                    self?.copy(option)
                },
                UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                    self?.editOption(row: row)
                }
            ])
        })
    }
    
    private func copy(_ option: (String, String)) {
        guard !option.1.isEmpty else { return }
        UIPasteboard.general.string = option.1
        showToast("\(option.0) copied")
    }
    
    // MARK: Editing
    
    private func editOption(row: Int, onSave: (() -> Void)? = nil) {
        let item = options[row]
        EditValueViewController.present(from: self, title: item.0, value: item.1) { [weak self] value in
            self?.applyEdit(row: row, value: value)
            onSave?()
        }
    }
    
    private func applyEnvironment(_ env: CourierEnvironment) {
        selectedEnvironment = env
        options[0].1 = env.name
        
        let userManager = UserManager.shared
        userManager.setCredential(key: "environment", value: env.name)
        
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
        
        reloadItems()
    }
    
    private func applyEdit(row: Int, value: String) {
        options[row].1 = value
        
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
            options[0].1 = CourierEnvironment.custom.name
            userManager.setCredential(key: "environment", value: CourierEnvironment.custom.name)
        }
        
        reloadItems()
    }
    
    // MARK: Auth
    
    private func setWorking(_ working: Bool) {
        isWorking = working
        reloadItems()
    }
    
    private func signIn() async {
        
        let userId = options[1].1
        let tenantId = options[2].1.isEmpty ? nil : options[2].1
        let apiKey = options[3].1
        
        // Ask for the user ID, then carry on signing in once it's set
        guard !userId.isEmpty else {
            editOption(row: 1) { [weak self] in
                guard let self, !self.options[1].1.isEmpty else { return }
                Task { await self.signIn() }
            }
            return
        }
        
        setWorking(true)
        defer { setWorking(false) }
        
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
            showCode(title: "Sign In Error", code: "\(error)")
        }
        
    }
    
    private func signOut() async {
        setWorking(true)
        await Courier.shared.signOut()
        setWorking(false)
    }
    
    deinit {
        authListener?.remove()
    }
}
