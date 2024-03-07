//
//  CourierPreferences.swift
//  
//
//  Created by https://github.com/mikemilla on 2/26/24.
//

import UIKit

// TODO:
// 1. Fallbacks for business tier
// 2. Brands
// 3. UI view heirachy stuff

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
@objc open class CourierPreferences: UIView, UITableViewDelegate, UITableViewDataSource, UISheetPresentationControllerDelegate {
    
    // MARK: Theme
    
    private let availableChannels: [CourierUserPreferencesChannel]
    
    private let lightTheme: CourierPreferencesTheme
    private let darkTheme: CourierPreferencesTheme
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierPreferencesTheme = .defaultLight
    
    // MARK: Data
    
    private(set) var preferences: [String : [CourierUserPreferencesTopic]] = [:]
    
    // MARK: UI
    
    @objc public let tableView = UITableView(frame: .zero, style: .grouped)
    private let infoView = CourierInfoView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private let courierBar = CourierBar()
    private var sheetViewController: PreferencesSheetViewController?
    
    // MARK: Constraints
    
    private var infoViewY: NSLayoutConstraint? = nil
    
    // MARK: State
    
    private var state: State = .loading {
        didSet {
            
            // Update UI
            switch (state) {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = true
            case .error:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
                self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No preferences found")
            case .content:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.infoView.isHidden = true
            case .empty:
                self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.infoView.isHidden = false
                self.infoView.updateView(state, actionTitle: "Retry", contentTitle: "No preferences found")
            }
            
            // Scroll to top if needed
            if ("\(oldValue)" != "\(state)") {
                self.scrollToTop(animated: false)
            }
            
        }
    }
    
    public init(
        availableChannels: [CourierUserPreferencesChannel] = CourierUserPreferencesChannel.allCases,
        lightTheme: CourierPreferencesTheme = .defaultLight,
        darkTheme: CourierPreferencesTheme = .defaultDark
    ) {
        
        if (availableChannels.isEmpty) {
            fatalError("Must pass at least 1 channel to the CourierPreferences initializer.")
        }
        
        self.availableChannels = availableChannels
        
        // Theme
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        super.init(frame: .zero)
        setup()
        
    }
    
    override init(frame: CGRect) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.availableChannels = CourierUserPreferencesChannel.allCases
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        [tableView, courierBar, infoView, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Set state
        state = .loading
        
        // Add the views
        addTableView()
        addLoadingIndicator()
        addInfoView()
        addCourierBar()
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        refresh()
        
    }
    
    @objc func refresh() {
        
        Task {
            
            refreshControl.beginRefreshing()
            
            do {
                
                let prefs = try await Courier.shared.getUserPreferences()
                
                // Map to section names
                preferences = prefs.items.reduce(into: [:]) { result, item in
                    if var array = result[item.sectionName] {
                        array.append(item)
                        result[item.sectionName] = array
                    } else {
                        result[item.sectionName] = [item]
                    }
                }
                
                // Reload the state
                tableView.reloadData()
                state = preferences.isEmpty ? .empty : .content
                
            } catch {
                
                state = .error(error)
                
            }
            
            refreshControl.endRefreshing()
            
            
        }
        
    }
    
    @objc public func scrollToTop(animated: Bool) {
        
        if (self.preferences.isEmpty) {
            return
        }
        
        self.tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
        
    }
    
    private func refreshCourierBarIfNeeded() {
        
        if (!courierBar.isHidden) {
         
            // Set the courier bar background color
            courierBar.setColors(with: superview?.backgroundColor)
            
            // Add content inset
            tableView.verticalScrollIndicatorInsets.bottom = Theme.Bar.barHeight
            tableView.contentInset.bottom = Theme.Bar.barHeight
            
            // Update position
            courierBar.bottomConstraint?.constant = -(tableView.adjustedContentInset.bottom - Theme.Bar.barHeight)
            courierBar.layoutIfNeeded()
            
            // Update infoView position
            infoViewY?.constant = -(Theme.Bar.barHeight / 2)
            infoView.layoutIfNeeded()
            
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        refreshCourierBarIfNeeded()
        
    }
    
    private func addCourierBar() {
        
        addSubview(courierBar)
        
        NSLayoutConstraint.activate([
            courierBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addTableView() {
        
        // Create the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourierPreferenceSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CourierPreferenceSectionHeaderView.id)
        tableView.register(CourierPreferenceTopicCell.self, forCellReuseIdentifier: CourierPreferenceTopicCell.id)

        // Add the refresh control
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
    private func addLoadingIndicator() {
        
        loadingIndicator.hidesWhenStopped = true
        
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    private func addInfoView() {
        
        // Refresh the inbox
        infoView.onButtonClick = { [weak self] in
            self?.state = .loading
            self?.onRefresh()
        }
        
        addSubview(infoView)
        
        infoViewY = infoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            infoViewY!,
            infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (Theme.margin / 2)),
            infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(Theme.margin / 2)),
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
        
        // Table theme
        tableView.separatorStyle = self.theme.topicCellStyles.separatorStyle
        tableView.separatorInset = self.theme.topicCellStyles.separatorInsets
        tableView.separatorColor = self.theme.topicCellStyles.separatorColor
        
        // Loading indicators
        tableView.refreshControl?.tintColor = self.theme.loadingColor
        loadingIndicator.color = self.theme.loadingColor
        
        // Update all cells
        tableView.reloadData()
        
    }
    
    @objc private func onRefresh() {
        refresh()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        print("Section count: \(preferences.keys.count)")
        return preferences.keys.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Items in section count: \(getTopicsForSection(at: section).count)")
        print(getTopicsForSection(at: section).count)
        return getTopicsForSection(at: section).count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard !preferences.isEmpty else {
            return nil
        }
        
        let sectionName = Array(preferences.keys)[section]
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CourierPreferenceSectionHeaderView.id) as! CourierPreferenceSectionHeaderView
        
        headerView.configureCell(title: sectionName)
        headerView.setTheme(theme: self.theme)
        
        return headerView
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CourierPreferenceTopicCell.id, for: indexPath) as! CourierPreferenceTopicCell

        let topic = getTopicsForSection(at: indexPath.section)[indexPath.row]
        cell.configureCell(
            topic: topic, 
            availableChannels: self.availableChannels,
            onEditButtonClick: {
                self.tableView(tableView, didSelectRowAt: indexPath)
            }
        )
        cell.setTheme(theme: self.theme)

        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Present the sheet
        let topic = getTopicsForSection(at: indexPath.section)[indexPath.row]
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
    
    private func getTopicsForSection(at index: Int) -> [CourierUserPreferencesTopic] {
        let sectionName = Array(preferences.keys)[index]
        return preferences[sectionName] ?? []
    }
    
    private func showSheet(topic: CourierUserPreferencesTopic) {
        
        guard let parentViewController = parentViewController else {
            fatalError("CourierPreferences must be added to a view hierarchy with a ViewController.")
        }
        
        var items = [CourierSheetItem]()
        
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
        
        // Build the sheet
        sheetViewController = PreferencesSheetViewController(
            theme: theme,
            topic: topic,
            items: items,
            onDismiss: { items in
                
                // Unable to save. Settings required.
                if (topic.defaultStatus == .required && topic.status == .required) {
                    return
                }
                
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
                
                // Update the Topic
                Courier.shared.putUserPreferencesTopic(
                    topicId: topic.topicId,
                    status: newStatus,
                    hasCustomRouting: hasCustomRouting,
                    customRouting: customRouting,
                    onSuccess: {
                        Courier.log("Topic updated: \(topic.topicId)")
                    },
                    onFailure: { error in
                        Courier.log(error.localizedDescription)
                        self.updateTopic(topicId: topic.topicId, newTopic: topic)
                    }
                )
                
                // Remove the sheet reference
                self.sheetViewController = nil
                
            }
        )
        
        // Present the sheet
        parentViewController.present(sheetViewController!, animated: true, completion: nil)
        
    }
    
    private func updateTopic(topicId: String, newTopic: CourierUserPreferencesTopic) {
        DispatchQueue.main.async {
            for (sectionName, topics) in self.preferences {
                if let index = topics.firstIndex(where: { $0.topicId == topicId }) {
                    self.preferences[sectionName]?[index] = newTopic
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: Array(self.preferences.keys).firstIndex(of: sectionName) ?? 0)], with: .fade)
                    return
                }
            }
        }
    }
    
}

extension CourierUserPreferencesTopic {
    
    @objc func convertToJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting to JSON: \(error.localizedDescription)")
        }
        return nil
    }
    
}
