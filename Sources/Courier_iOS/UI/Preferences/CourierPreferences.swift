//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
open class CourierPreferences: UIView, UITableViewDelegate, UITableViewDataSource, UISheetPresentationControllerDelegate {
    
    public typealias CustomListItemView = (_ view: CourierPreferences, _ topic: CourierUserPreferencesTopic, _ section: Int, _ index: Int) -> UIView
    public typealias CustomLoadingStateView = () -> UIView
    public typealias CustomEmptyStateView = (_ onRetry: @escaping () -> Void) -> UIView
    public typealias CustomErrorStateView = (_ message: String, _ onRetry: @escaping () -> Void) -> UIView
    
    // MARK: Theme
    
    public enum Mode {
        case topic
        case channels([CourierUserPreferencesChannel])
    }
    
    private let mode: Mode
    
    private var lightTheme: CourierPreferencesTheme
    private var darkTheme: CourierPreferencesTheme

    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierPreferencesTheme = .defaultLight
    
    // MARK: Custom Views
    
    private static let customListItemId = "CustomPreferenceListItem"
    private let customListItem: CustomListItemView?
    private let customLoadingState: CustomLoadingStateView?
    private let customEmptyState: CustomEmptyStateView?
    private let customErrorState: CustomErrorStateView?
    private var activeStateView: UIView? = nil
    
    // MARK: Data
    
    internal struct Section {
        let title: String
        let id: String
        var topics: [CourierUserPreferencesTopic]
    }
    
    // MARK: Interaction
    
    public var didScrollPreferences: ((UIScrollView) -> Void)? = nil
    
    // MARK: Authentication
    
    private var authListener: CourierAuthenticationListener? = nil
    
    private(set) var preferences = [CourierPreferences.Section]()
    
    // MARK: Subviews
    
    private var sheetViewController: PreferencesSheetViewController?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        if customListItem != nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: CourierPreferences.customListItemId)
        }
        tableView.register(CourierPreferenceSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CourierPreferenceSectionHeaderView.id)
        tableView.register(CourierPreferenceTopicCell.self, forCellReuseIdentifier: CourierPreferenceTopicCell.id)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return tableView
    }()
    
    private lazy var infoView: CourierInfoView = {
        let infoView = CourierInfoView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.onButtonClick = { [weak self] in
            self?.state = .loading
            self?.onRefresh()
        }
        return infoView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        return loadingIndicator
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
    
    private lazy var stateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: Constraints
    
    private var infoViewY: NSLayoutConstraint?
    
    // MARK: State
    
    private var state: State = .loading {
        didSet {
            
            switch (state) {
            case .loading:
                if let customLoadingState = self.customLoadingState {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = true
                    self.showStateView(customLoadingState())
                } else {
                    self.hideStateView()
                    self.loadingIndicator.startAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = true
                }
            case .error(let message):
                if let customErrorState = self.customErrorState {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = true
                    self.showStateView(customErrorState(message, { [weak self] in
                        self?.retry()
                    }))
                } else {
                    self.hideStateView()
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = false
                    self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No preferences found")
                }
            case .content:
                self.hideStateView()
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.infoView.isHidden = true
            case .empty:
                if let customEmptyState = self.customEmptyState {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = true
                    self.showStateView(customEmptyState({ [weak self] in
                        self?.retry()
                    }))
                } else {
                    self.hideStateView()
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.infoView.isHidden = false
                    self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No preferences found")
                }
            }
            
            // Scroll to top if needed
            if ("\(oldValue)" != "\(state)") {
                self.scrollToTop(animated: false)
            }
            
        }
    }
    
    // MARK: Error handling
    
    private var onError: ((CourierError) -> String)? = nil
    
    public init(
        mode: CourierPreferences.Mode = .channels(CourierUserPreferencesChannel.allCases),
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark,
        customListItem: CustomListItemView? = nil,
        customLoadingState: CustomLoadingStateView? = nil,
        customEmptyState: CustomEmptyStateView? = nil,
        customErrorState: CustomErrorStateView? = nil,
        didScrollPreferences: ((UIScrollView) -> Void)? = nil,
        onError: ((CourierError) -> String)? = nil
    ) {
        self.mode = mode
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        self.customListItem = customListItem
        self.customLoadingState = customLoadingState
        self.customEmptyState = customEmptyState
        self.customErrorState = customErrorState
        self.didScrollPreferences = didScrollPreferences
        self.onError = onError
        super.init(frame: .zero)
        setup()
    }
    
    // MARK: Other Initializers
    
    override init(frame: CGRect) {
        self.mode = .channels(CourierUserPreferencesChannel.allCases)
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.customListItem = nil
        self.customLoadingState = nil
        self.customEmptyState = nil
        self.customErrorState = nil
        self.onError = nil
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.mode = .channels(CourierUserPreferencesChannel.allCases)
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.customListItem = nil
        self.customLoadingState = nil
        self.customEmptyState = nil
        self.customErrorState = nil
        self.onError = nil
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        Task {
            
            // Called when the auth state changes
            authListener = await Courier.shared.addAuthenticationListener { [weak self] userId in
                
                if (userId != nil) {
                    self?.traitCollectionDidChange(nil)
                    self?.state = .loading
                }
                
                self?.onRefresh()
                
            }
            
        }
        
        // Add the views
        addTableView()
        addLoadingIndicator()
        addInfoView()
        addStateContainer()
        
        // Set state
        state = .loading
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Grab details
        refresh()
        
    }
    
    private func retry() {
        state = .loading
        onRefresh()
    }
    
    func refresh() {
        
        Task {
            
            refreshControl.beginRefreshing()
            
            do {
                
                if await !Courier.shared.isUserSignedIn {
                    throw CourierError.userNotFound
                }
                
                // Fetch the brand if needed
                if let brandId = self.theme.brandId {
                    let res = try await Courier.shared.client?.brands.getBrand(brandId: brandId)
                    theme.brand = res?.data.brand
                }
                
                let prefs = try await Courier.shared.client?.preferences.getUserPreferences()
                
                var sections = [CourierPreferences.Section]()
                
                prefs?.items.forEach { topic in
                    
                    let sectionId = topic.sectionId
                    
                    // Add the item to the proper section
                    if let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) {
                        
                        sections[sectionIndex].topics.append(topic)
                        
                    } else {
                        
                        let newSection = CourierPreferences.Section(
                            title: topic.sectionName,
                            id: topic.sectionId,
                            topics: [topic]
                        )
                        
                        sections.append(newSection)
                        
                    }
                    
                }
                
                self.preferences = sections
                
                // Reload the state
                reloadViews()
                state = preferences.isEmpty ? .empty : .content
                
            } catch {
                
                let courierError = CourierError(from: error)
                let message = self.onError?(courierError)
                state = .error(message ?? courierError.message)
                
            }
            
            refreshControl.endRefreshing()
            
            
        }
        
    }
    
    public func scrollToTop(animated: Bool) {
        
        if (self.preferences.isEmpty) {
            return
        }
        
        self.tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
        
    }
    
    private func addTableView() {
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addLoadingIndicator() {
        
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    private func addInfoView() {
        
        addSubview(infoView)
        
        infoViewY = infoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            infoViewY!,
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (Theme.margin / 2)),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(Theme.margin / 2)),
        ])
        
    }
    
    private func addStateContainer() {
        addSubview(stateContainer)
        
        NSLayoutConstraint.activate([
            stateContainer.topAnchor.constraint(equalTo: topAnchor),
            stateContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            stateContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            stateContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func showStateView(_ view: UIView) {
        activeStateView?.removeFromSuperview()
        activeStateView = view
        view.translatesAutoresizingMaskIntoConstraints = false
        stateContainer.isHidden = false
        stateContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stateContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: stateContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
        ])
    }
    
    private func hideStateView() {
        activeStateView?.removeFromSuperview()
        activeStateView = nil
        stateContainer.isHidden = true
    }
    
    private func renderCustomView(in cell: UITableViewCell, view: UIView) {
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
        ])
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
            reloadViews()
        }
        
    }
    
    private func setTheme(isDarkMode: Bool) {
        theme = isDarkMode ? darkTheme : lightTheme
    }
    
    private func reloadViews() {
        
        sheetViewController?.setTheme(theme: self.theme)
        
        // Background
        tableView.backgroundColor = self.theme.backgroundColor
        
        // Table theme
        if self.customListItem == nil {
            tableView.separatorStyle = self.theme.topicCellStyles.separatorStyle
            tableView.separatorInset = self.theme.topicCellStyles.separatorInsets
            tableView.separatorColor = self.theme.topicCellStyles.separatorColor
        } else {
            tableView.separatorStyle = .none
            tableView.separatorInset = .zero
            tableView.separatorColor = nil
        }
        
        // Loading indicators
        tableView.refreshControl?.tintColor = self.theme.loadingColor
        loadingIndicator.color = self.theme.loadingColor
        
        // Update all cells
        tableView.reloadData()
        
        // Update infoview
        infoView.setTheme(theme)
        
    }
    
    @objc private func onRefresh() {
        refresh()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollPreferences?(scrollView)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences[section].topics.count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard !preferences.isEmpty else {
            return nil
        }
        
        let sectionName = preferences[section].title
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CourierPreferenceSectionHeaderView.id) as! CourierPreferenceSectionHeaderView
        
        headerView.configureCell(title: sectionName)
        headerView.setTheme(theme: self.theme)
        
        return headerView
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = preferences[indexPath.section].topics[indexPath.row]
        
        if let customListItem = self.customListItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferences.customListItemId, for: indexPath)
            renderCustomView(in: cell, view: customListItem(self, topic, indexPath.section, indexPath.row))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceTopicCell.id, for: indexPath) as! CourierPreferenceTopicCell
        cell.configureCell(
            topic: topic,
            mode: self.mode,
            onEditButtonClick: {
                self.tableView(tableView, didSelectRowAt: indexPath)
            }
        )
        cell.setTheme(theme: self.theme)
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Present the sheet
        let topic = preferences[indexPath.section].topics[indexPath.row]
        showSheet(topic: topic)
        
        // Deselect the cell
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Theme.Preferences.topicSectionHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Preferences.topicCellHeight
    }
    
    public func showSheet(topic: CourierUserPreferencesTopic) {
        
        guard let parentViewController = parentViewController else {
            fatalError("CourierPreferences must be added to a view hierarchy with a ViewController.")
        }
        
        var items = [CourierSheetItem]()
        
        switch (self.mode) {
        case .topic:
            
            let isRequired = topic.status == .required
            
            var isOn = true
            
            if (!isRequired) {
                isOn = topic.status != .optedOut
            }
            
            let item = CourierSheetItem(
                title: "Receive Notifications",
                isOn: isOn,
                isDisabled: isRequired,
                data: nil
            )
            
            items.append(item)
            
        case .channels(let availableChannels):
            
            items = availableChannels.map { channel in
                
                let isRequired = topic.status == .required
                
                var isOn = true
                
                if (topic.customRouting.isEmpty) {
                    isOn = topic.status != .optedOut
                } else {
                    isOn = topic.customRouting.contains { $0.rawValue == channel.rawValue }
                }
                
                return CourierSheetItem(
                    title: channel.title,
                    isOn: isOn,
                    isDisabled: isRequired,
                    data: channel
                )
                
            }
            
        }
        
        // Build the sheet
        sheetViewController = PreferencesSheetViewController(
            theme: theme,
            topic: topic,
            items: items,
            onDismiss: { items in
                self.handleChangeForMode(mode: self.mode, topic: topic, items: items)
                self.sheetViewController = nil
            }
        )
        
        // Present the sheet
        parentViewController.present(sheetViewController!, animated: true, completion: nil)
        
    }
    
    private func handleChangeForMode(mode: Mode, topic: CourierUserPreferencesTopic, items: [CourierSheetItem]) {
        
        if (topic.defaultStatus == .required && topic.status == .required) {
            return
        }
        
        switch (mode) {
        case .topic:
            
            let selectedItems = items.filter { $0.isOn }
            let isSelected = !selectedItems.isEmpty
            
            if (topic.status == .optedIn && isSelected) {
                return
            }
            
            if (topic.status == .optedOut && !isSelected) {
                return
            }
            
            let newStatus: CourierUserPreferencesStatus = isSelected ? .optedIn : .optedOut
            
            let newTopic = CourierUserPreferencesTopic(
                defaultStatus: topic.defaultStatus.rawValue,
                hasCustomRouting: false,
                customRouting: [],
                status: newStatus.rawValue,
                topicId: topic.topicId,
                topicName: topic.topicName,
                sectionName: topic.sectionName,
                sectionId: topic.sectionId
            )

            // Unchanged
            if (newTopic.isEqual(to: topic)) {
                return
            }

            self.updateTopic(topicId: topic.topicId, newTopic: newTopic)

            Task {
                
                // Update the Topic
                do {
                    try await Courier.shared.client?.preferences.putUserPreferenceTopic(
                        topicId: topic.topicId,
                        status: newStatus,
                        hasCustomRouting: newTopic.hasCustomRouting,
                        customRouting: newTopic.customRouting
                    )
                    await Courier.shared.client?.log("Topic updated: \(topic.topicId)")
                } catch {
                    await Courier.shared.client?.log(error.localizedDescription)
                    let _ = self.onError?(CourierError(from: error))
                    self.updateTopic(topicId: topic.topicId, newTopic: topic)
                }
                
            }
            
        case .channels(_):

            let selectedItems = items.filter { $0.isOn }.map { $0.data as! CourierUserPreferencesChannel }

            var newStatus: CourierUserPreferencesStatus = .unknown

            if (selectedItems.isEmpty) {
                newStatus = .optedOut
            } else {
                newStatus = .optedIn
            }

            var hasCustomRouting = false
            var customRouting = [CourierUserPreferencesChannel]()
            let areAllSelected = selectedItems.count == items.count

            if (areAllSelected && topic.defaultStatus == .optedIn) {
                hasCustomRouting = false
                customRouting = []
            } else if (selectedItems.isEmpty && topic.defaultStatus == .optedOut) {
                hasCustomRouting = false
                customRouting = []
            } else {
                hasCustomRouting = true
                customRouting = selectedItems
            }

            let newTopic = CourierUserPreferencesTopic(
                defaultStatus: topic.defaultStatus.rawValue,
                hasCustomRouting: hasCustomRouting,
                customRouting: customRouting.map { $0.rawValue },
                status: newStatus.rawValue,
                topicId: topic.topicId,
                topicName: topic.topicName,
                sectionName: topic.sectionName,
                sectionId: topic.sectionId
            )

            // Unchanged
            if (newTopic.isEqual(to: topic)) {
                return
            }

            self.updateTopic(topicId: topic.topicId, newTopic: newTopic)
            
            Task {
                
                // Update the Topic
                do {
                    try await Courier.shared.client?.preferences.putUserPreferenceTopic(
                        topicId: topic.topicId,
                        status: newStatus,
                        hasCustomRouting: hasCustomRouting,
                        customRouting: customRouting
                    )
                    await Courier.shared.client?.log("Topic updated: \(topic.topicId)")
                } catch {
                    await Courier.shared.client?.log(error.localizedDescription)
                    let _ = self.onError?(CourierError(from: error))
                    self.updateTopic(topicId: topic.topicId, newTopic: topic)
                }
                
            }
            
        }
        
    }
    
    private func updateTopic(topicId: String, newTopic: CourierUserPreferencesTopic) {
        DispatchQueue.main.async {
            for (sectionIndex, section) in self.preferences.enumerated() {
                if let topicIndex = section.topics.firstIndex(where: { $0.topicId == topicId }) {
                    self.preferences[sectionIndex].topics[topicIndex] = newTopic
                    self.tableView.reloadRows(at: [IndexPath(row: topicIndex, section: sectionIndex)], with: .fade)
                    return
                }
            }
        }
    }
    
    /**
     Clear the listeners
     */
    deinit {
        Task { [self] in
            await self.authListener?.remove()
        }
    }

    // MARK: Theme update

    public func update(darkTheme: CourierPreferencesTheme? = nil, lightTheme: CourierPreferencesTheme? = nil) {
        if let darkTheme = darkTheme {
            self.darkTheme = darkTheme
        }
        if let lightTheme = lightTheme {
            self.lightTheme = lightTheme
        }
        // Refreshes theme
        traitCollectionDidChange(nil)
    }
}
