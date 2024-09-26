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
open class CourierInbox: UIView, UIScrollViewDelegate {
    
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .purple
        return stackView
    }()
    
    private lazy var tabs: TabView = {
        
//        let pages = [
//            Page(title: "Notifications", page: makeInboxList(supportedMessageStates: [.read, .unread])),
//            Page(title: "Archived", page: makeInboxList(supportedMessageStates: [.archived]))
//        ]
        
        let page1 = UIView()
        page1.translatesAutoresizingMaskIntoConstraints = false
        page1.backgroundColor = .blue
        
        let page2 = UIView()
        page2.translatesAutoresizingMaskIntoConstraints = false
        page2.backgroundColor = .orange
        
        let pages = [
            Page(title: "Notifications", page: page1),
            Page(title: "Archived", page: page2)
        ]
        
        let tabs = TabView(pages: pages, onTabSelected: { [weak self] index in
            self?.updateScrollViewToPage(index)
        })
        
        tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.heightAnchor.constraint(equalToConstant: Theme.Bar.barHeight).isActive = true
        
        return tabs
        
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private let courierBar: CourierBar = {
        let courierBar = CourierBar()
        courierBar.translatesAutoresizingMaskIntoConstraints = false
        courierBar.heightAnchor.constraint(equalToConstant: Theme.Bar.barHeight).isActive = true
        return courierBar
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
        addStack(
            top: tabs,
            middle: scrollView,
            bottom: courierBar
        )
        
        // Add the pages
        addPagesToScrollView(tabs)
        
        // Refreshes theme
        traitCollectionDidChange(nil)
        
        // Init the listener
        makeListener()
        
    }
    
    private func addStack(top: UIView, middle: UIView, bottom: UIView) {
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        stackView.addArrangedSubview(top)
        stackView.addArrangedSubview(middle)
        stackView.addArrangedSubview(bottom)
        
    }
    
    private func makeInboxList(supportedMessageStates: [InboxMessageListView.MessageState]) -> InboxMessageListView {
        let list = InboxMessageListView(supportedMessageStates: supportedMessageStates)
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }
    
    private func addPagesToScrollView(_ tabView: TabView) {
        
        // Iterate over each page and add it to the scrollView
        var previousPage: UIView? = nil
        
        // Get the pages from the tabview
        let pages = tabView.pages.map { $0.page }

        for (index, page) in pages.enumerated() {
            scrollView.addSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                page.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])

            if let previousPage = previousPage {
                NSLayoutConstraint.activate([
                    page.leadingAnchor.constraint(equalTo: previousPage.trailingAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    page.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
                ])
            }
            
            // If this is the last page, set the trailing anchor to the scrollView's trailing anchor
            if index == pages.count - 1 {
                NSLayoutConstraint.activate([
                    page.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                ])
            }

            // Keep a reference to the current page as the previous page for the next iteration
            previousPage = page
        }
        
    }
    
    private func updateScrollViewToPage(_ index: Int) {
        let pageWidth = scrollView.frame.size.width
        let offset = CGPoint(x: pageWidth * CGFloat(index), y: 0)
        scrollView.setContentOffset(offset, animated: true)
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
        
        scrollView.subviews.forEach { page in
            page.frame.size.height = scrollView.frame.height
            page.frame.size.width = scrollView.frame.width
        }
        
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
    
    /**
     Clear the listeners
     */
    deinit {
        self.authListener?.remove()
        self.inboxListener?.remove()
    }
}
