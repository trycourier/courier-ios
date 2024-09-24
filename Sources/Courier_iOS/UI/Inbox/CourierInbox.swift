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
open class CourierInbox: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false // TODO
//        scrollView.delegate = self // Add this line
        scrollView.backgroundColor = .red
        return scrollView
    }()
    
    // MARK: Constraints
    
    private var scrollViewBottom: NSLayoutConstraint? = nil
    
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
        addScrollView()
        addPagesToScrollView()
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Init the listener
        makeListener()
        
    }
    
    private func toggleCourierBar(brand: CourierBrand?) {
        
        // Show or hide the bar
        courierBar.isHidden = !(brand?.settings?.inapp?.showCourierFooter ?? true)
        
        // Handle the updates
        if (!courierBar.isHidden) {
            
            // Set the courier bar background color
            courierBar.setColors(with: superview?.backgroundColor)
            
            scrollViewBottom?.constant = -Theme.Bar.barHeight
            scrollView.layoutIfNeeded()
            
        } else {
            
            scrollViewBottom?.constant = 0
            scrollView.layoutIfNeeded()
            
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        toggleCourierBar(brand: theme.brand)
    }
    
    private func addScrollView() {
        
        // Add the container
        addSubview(scrollView)
        
        scrollViewBottom = scrollView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -Theme.Bar.barHeight
        )
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollViewBottom!
        ])
        
    }
    
    private func makeInboxList() -> InboxListView {
        let list = InboxListView()
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }
    
    private func addPagesToScrollView() {
        
        let page1 = makeInboxList()
        let page2 = makeInboxList()

        scrollView.addSubview(page1)
        scrollView.addSubview(page2)

        NSLayoutConstraint.activate([
            
            page1.topAnchor.constraint(equalTo: scrollView.topAnchor),
            page1.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            page1.widthAnchor.constraint(equalTo: widthAnchor),
            page1.heightAnchor.constraint(equalTo: heightAnchor),

            // Page 2 constraints
            page2.topAnchor.constraint(equalTo: scrollView.topAnchor),
            page2.leadingAnchor.constraint(equalTo: page1.trailingAnchor),
            page2.widthAnchor.constraint(equalTo: widthAnchor),
            page2.heightAnchor.constraint(equalTo: heightAnchor),
            
            // ScrollView content size to fit both pages
            page2.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
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
            self.toggleCourierBar(brand: self.theme.brand)
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
        toggleCourierBar(brand: theme.brand)
    }
    
    // MARK: ScrollView Delegates
    
    private func getCurrentPageIndex() -> Int {
        let pageWidth = scrollView.frame.size.width
        let fractionalPageIndex = scrollView.contentOffset.x / pageWidth
        let pageIndex = Int(fractionalPageIndex.rounded())
        return pageIndex
    }
    
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let otherView = otherGestureRecognizer.view, otherView.isKind(of: UITableView.self) {
//            if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//                
//                let velocity = panGestureRecognizer.velocity(in: self)
//                
//                let currentPage = getCurrentPageIndex()
//                let minimumVelocity: CGFloat = 100.0
//
//                if currentPage == 0 {
//                    return velocity.x > minimumVelocity && velocity.x > (0.5 * abs(velocity.y))
//                } else if currentPage == 1 {
//                    return velocity.x < -minimumVelocity && abs(velocity.x) > (0.5 * abs(velocity.y))
//                }
//                
//            }
//        }
//        return false
//    }
    
    /**
     Clear the listeners
     */
    deinit {
        self.authListener?.remove()
        self.inboxListener?.remove()
    }
}
