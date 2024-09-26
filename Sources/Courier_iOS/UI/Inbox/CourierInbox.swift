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
    
    // MARK: Interaction
    
    private let canSwipePages: Bool
    private let pagingDuration: TimeInterval
    
    // MARK: Theme
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
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
        scrollView.backgroundColor = .red
        scrollView.delegate = self
        return scrollView
    }()
    
    private let courierBar: CourierBar = {
        let courierBar = CourierBar()
        courierBar.translatesAutoresizingMaskIntoConstraints = false
        courierBar.heightAnchor.constraint(equalToConstant: Theme.Bar.barHeight).isActive = true
        return courierBar
    }()
    
    // MARK: Authentication
    
    private var authListener: CourierAuthenticationListener? = nil
    
    // MARK: Init
    
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        
        self.canSwipePages = canSwipePages
        self.pagingDuration = pagingDuration
        
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        super.init(frame: .zero)
        
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        
        setup()
    }

    override init(frame: CGRect) {
        self.canSwipePages = false
        self.pagingDuration = 0.1
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.canSwipePages = false
        self.pagingDuration = 0.1
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        authListener = Courier.shared.addAuthenticationListener { [weak self] userId in
            if (userId != nil) {
                self?.traitCollectionDidChange(nil)
            }
        }

        addStack(
            top: tabs,
            middle: scrollView,
            bottom: courierBar
        )
        
        addPagesToScrollView(tabs)
        
        traitCollectionDidChange(nil)
        
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
        let pages = tabView.pages.map { $0.page }

        for (index, page) in pages.enumerated() {
            scrollView.addSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            
            // Set constraints for the page
            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                page.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                page.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])

            // Set leading anchor for the page
            if index == 0 {
                NSLayoutConstraint.activate([
                    page.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
                ])
            } else {
                let previousPage = scrollView.subviews[index - 1]
                NSLayoutConstraint.activate([
                    page.leadingAnchor.constraint(equalTo: previousPage.trailingAnchor)
                ])
            }

            // Set trailing anchor for the last page
            if index == pages.count - 1 {
                NSLayoutConstraint.activate([
                    page.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                ])
            }
        }
    }
    
    private func updateScrollViewToPage(_ index: Int) {
        let pageWidth = scrollView.frame.size.width
        let offset = CGPoint(x: pageWidth * CGFloat(index), y: 0)
        UIView.animate(
            withDuration: self.pagingDuration,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
               self.scrollView.setContentOffset(offset, animated: false)
            }, completion: nil
        )
    }
    
    private func toggleCourierBar(brand: CourierBrand?) {
        courierBar.isHidden = !(brand?.settings?.inapp?.showCourierFooter ?? true)
        if !courierBar.isHidden {
            courierBar.setColors(with: superview?.backgroundColor)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        toggleCourierBar(brand: theme.brand)
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
    
    private func refreshBrand() async throws {
        if let brandId = self.theme.brandId {
            let res = try await Courier.shared.client?.brands.getBrand(brandId: brandId)
            self.theme.brand = res?.data.brand
            self.toggleCourierBar(brand: self.theme.brand)
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
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
        return Int(fractionalPageIndex.rounded())
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tabs.selectedIndex = getCurrentPageIndex()
    }
    
    deinit {
        self.authListener?.remove()
        self.inboxListener?.remove()
    }
    
}
