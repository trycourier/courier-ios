//
//  CourierInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit

/**
 A super simple way to implement a basic notification center into your app
 */
@available(iOSApplicationExtension, unavailable)
open class CourierInbox: UIView {
    
    // MARK: Theme
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
    // Sets the theme and propagates the change
    // Defaults to light mode, but will change when the theme is set
    private var theme: CourierInboxTheme = .defaultLight
    
    // MARK: Interaction
    
    public var didClickInboxMessageAtIndex: ((InboxMessage, Int) -> Void)? = nil
    public var didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil
    public var didScrollInbox: ((UIScrollView) -> Void)? = nil
    
    // MARK: Datasource
    
    private var inboxListener: CourierInboxListener? = nil
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    // MARK: UI
    
    private let courierBar: CourierBar = {
        let courierBar = CourierBar()
        courierBar.translatesAutoresizingMaskIntoConstraints = false
        return courierBar
    }()
    
    private lazy var contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .blue
        return container
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .red
        return scrollView
    }()
    
    // MARK: Constraints
    
    private var contentViewBottom: NSLayoutConstraint? = nil
    
    // MARK: Authentication
    
    private var authListener: CourierAuthenticationListener? = nil
    
    // MARK: Init
    
    public init(
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        // Theme
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        // Init
        super.init(frame: .zero)
        
        // Callbacks
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        
        // Styles and more
        setup()
    }

    override init(frame: CGRect) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Called when the auth state changes
        authListener = Courier.shared.addAuthenticationListener { [weak self] userId in
            if (userId != nil) {
                self?.traitCollectionDidChange(nil)
//                self?.state = .loading
//                self?.onRefresh()
            }
        }

        // Add the views
        addCourierBar()
        addContent(
            content: scrollView
        )
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Init the listener
        makeListener()
        
    }
    
    private func updateViewForCourierBar() {
        
        if (!courierBar.isHidden) {
            
            // Set the courier bar background color
            courierBar.setColors(with: superview?.backgroundColor)
            
            contentViewBottom?.constant = -Theme.Bar.barHeight
            contentView.layoutIfNeeded()
            
        } else {
            
            contentViewBottom?.constant = 0
            contentView.layoutIfNeeded()
            
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateViewForCourierBar()
    }
    
    private func addContent(content: UIView) {
        
        // Add the container
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        contentViewBottom = contentView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -Theme.Bar.barHeight
        )
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentViewBottom!
        ])
        
    }
    
    private func addCourierBar() {
        addSubview(courierBar)
        
        NSLayoutConstraint.activate([
            courierBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            courierBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            courierBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func makeListener() {
        Task {
            do {
                try await refreshBrand()
            } catch {
                Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }
    
    // MARK: Reloading
    
    private func refreshBrand() async throws {
        if let brandId = self.theme.brandId {
            let res = try await Courier.shared.client?.brands.getBrand(brandId: brandId)
            self.theme.brand = res?.data.brand
            self.updateViewForCourierBar()
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handles setting the theme of the Inbox
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
        }
    }
    
    private func setTheme(isDarkMode: Bool) {
        theme = isDarkMode ? darkTheme : lightTheme
        updateViewForCourierBar()
    }
    
    /**
     Clear the listeners
     */
    deinit {
        self.authListener?.remove()
        self.inboxListener?.remove()
    }
}
