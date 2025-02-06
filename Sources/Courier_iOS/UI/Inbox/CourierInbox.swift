//
//  CourierInbox.swift
//  
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
open class CourierInbox: UIView, UIScrollViewDelegate {
    
    // MARK: Interaction
    
    private let canSwipePages: Bool
    private let pagingDuration: TimeInterval
    
    // MARK: Theme
    
    private let lightTheme: CourierInboxTheme
    private let darkTheme: CourierInboxTheme
    
    private var theme: CourierInboxTheme = .defaultLight
    
    // MARK: Custom List Item
    
    private let customListItem: ((Int, InboxMessage) -> UIView)?
    
    // MARK: Interaction
    
    public var didClickInboxMessageAtIndex: ((InboxMessage, Int) -> Void)? = nil
    public var didLongPressInboxMessageAtIndex: ((InboxMessage, Int) -> Void)? = nil
    public var didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil
    public var didScrollInbox: ((UIScrollView) -> Void)? = nil
    
    // MARK: UI
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemBackground
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var messagesPage = {
        return Page(
            title: "Notifications",
            page: makeInboxList(.feed)
        )
    }()
    
    private lazy var archivedPage = {
        return Page(
            title: "Archived",
            page: makeInboxList(.archived)
        )
    }()
    
    private func getPages() -> [Page] {
        return [
            messagesPage,
            archivedPage,
        ]
    }
    
    private lazy var tabView: TabView = {
        
        let tabs = TabView(
            pages: getPages(),
            scrollView: scrollView,
            onTabSelected: { [weak self] index in
                self?.updateScrollViewToPage(index)
            },
            onTabReselected: { [weak self] index in
                self?.updateScrollViewToPage(index)
                self?.getPages()[index].page.scrollToTop(animated: true)
            }
        )
        
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
        scrollView.bounces = self.canSwipePages
        scrollView.isScrollEnabled = self.canSwipePages
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let courierBar: CourierBar = {
        let courierBar = CourierBar()
        courierBar.translatesAutoresizingMaskIntoConstraints = false
        courierBar.heightAnchor.constraint(equalToConstant: Theme.Bar.barHeight).isActive = true
        return courierBar
    }()
    
    // MARK: Listeners
    
    private var inboxListener: CourierInboxListener? = nil
    
    // MARK: Datasource
    
    private var inboxMessages: [InboxMessage] = []
    private var canPaginate = false
    
    // MARK: Init
    
    public init(
        canSwipePages: Bool = false,
        pagingDuration: TimeInterval = 0.1,
        lightTheme: CourierInboxTheme = .defaultLight,
        darkTheme: CourierInboxTheme = .defaultDark,
    customListItem: ((Int, InboxMessage) -> UIView)? = nil,
        didClickInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didLongPressInboxMessageAtIndex: ((_ message: InboxMessage, _ index: Int) -> Void)? = nil,
        didClickInboxActionForMessageAtIndex: ((InboxAction, InboxMessage, Int) -> Void)? = nil,
        didScrollInbox: ((UIScrollView) -> Void)? = nil
    ) {
        
        self.canSwipePages = canSwipePages
        self.pagingDuration = pagingDuration
        
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        
        self.customListItem = customListItem
        
        super.init(frame: .zero)
        
        self.didClickInboxMessageAtIndex = didClickInboxMessageAtIndex
        self.didLongPressInboxMessageAtIndex = didLongPressInboxMessageAtIndex
        self.didClickInboxActionForMessageAtIndex = didClickInboxActionForMessageAtIndex
        self.didScrollInbox = didScrollInbox
        
        setup()
    }

    override init(frame: CGRect) {
        self.canSwipePages = false
        self.pagingDuration = 0.1
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.customListItem = nil
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.canSwipePages = false
        self.pagingDuration = 0.1
        self.lightTheme = .defaultLight
        self.darkTheme = .defaultDark
        self.customListItem = nil
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        addStack(
            top: tabView,
            middle: scrollView,
            bottom: courierBar
        )
        
        addPagesToScrollView(tabView)
        
        traitCollectionDidChange(nil)
        
        self.getPages().forEach { page in
            page.page.setLoading()
        }
        
        // Perform an async function here
        Task { [weak self] in
            
            guard let self = self else { return }
            
            await self.refreshBrand()
            
            self.inboxListener = await Courier.shared.addInboxListener(
                onLoading: { [weak self] isRefresh in
                    if !isRefresh {
                        self?.getPages().forEach { page in
                            page.page.setLoading()
                        }
                    }
                },
                onError: { [weak self] error in
                    self?.getPages().forEach { page in
                        page.page.setError(error)
                    }
                },
                onUnreadCountChanged: { [weak self] count in
                    if let tabs = self?.tabView.tabs {
                        if (!tabs.isEmpty) {
                            tabs[0].badge = count
                        }
                    }
                },
                onFeedChanged: { [weak self] set in
                    Task { [weak self] in
                        await self?.getPage(for: .feed).page.setInbox(set: set)
                    }
                },
                onArchiveChanged: { set in
                    Task { [weak self] in
                        await self?.getPage(for: .archived).page.setInbox(set: set)
                    }
                },
                onPageAdded: { feed, set in
                    Task { [weak self] in
                        await self?.getPage(for: feed).page.addPage(set: set)
                    }
                },
                onMessageChanged: { feed, index, message in
                    Task { [weak self] in
                        self?.getPage(for: feed).page.updateMessage(at: index, message: message)
                    }
                },
                onMessageAdded: { feed, index, message in
                    Task { [weak self] in
                        await self?.getPage(for: feed).page.addMessage(at: index, message: message)
                    }
                },
                onMessageRemoved: { feed, index, message in
                    Task { [weak self] in
                        self?.getPage(for: feed).page.removeMessage(at: index, message: message)
                    }
                }
            )
            
        }
        
    }
    
    private func getPage(for feed: InboxMessageFeed) -> Page {
        return self.getPages()[feed == .feed ? 0 : 1]
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
    
    private func makeInboxList(_ feed: InboxMessageFeed) -> InboxMessageListView {
        let list = InboxMessageListView(
            feed: feed,
            customListItem: self.customListItem,
            didClickInboxMessageAtIndex: { [weak self] message, index in
                self?.didClickInboxMessageAtIndex?(message, index)
            },
            didLongPressInboxMessageAtIndex: { [weak self] message, index in
                self?.didLongPressInboxMessageAtIndex?(message, index)
            },
            didClickInboxActionForMessageAtIndex: { [weak self] action, message, index in
                self?.didClickInboxActionForMessageAtIndex?(action, message, index)
            },
            didScrollInbox: { [weak self] scrollView in
                self?.didScrollInbox?(scrollView)
            }
        )
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }
    
    private func addPagesToScrollView(_ tabView: TabView) {
        let pages = tabView.pages.map { $0.page }

        var previousPage: InboxMessageListView? = nil

        for (index, list) in pages.enumerated() {
            
            scrollView.addSubview(list)
            list.translatesAutoresizingMaskIntoConstraints = false
            list.canSwipePages = self.canSwipePages
            list.rootInbox = self
            
            // Set constraints for the page
            NSLayoutConstraint.activate([
                list.topAnchor.constraint(equalTo: scrollView.topAnchor),
                list.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                list.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                list.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            // Set leading anchor for the page
            if let previousPage = previousPage {
                NSLayoutConstraint.activate([
                    list.leadingAnchor.constraint(equalTo: previousPage.trailingAnchor)
                ])
            } else {
                // If it's the first page, anchor it to the scroll view's leading edge
                NSLayoutConstraint.activate([
                    list.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
                ])
            }

            // Set trailing anchor for the last page
            if index == pages.count - 1 {
                NSLayoutConstraint.activate([
                    list.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
                ])
            }
            
            // Update the reference to the previous page
            previousPage = list
            
        }
        
    }
    
    private func updateScrollViewToPage(_ index: Int) {
        let pageWidth = scrollView.frame.size.width
        let offset = CGPoint(x: pageWidth * CGFloat(index), y: 0)
        UIView.animate(
            withDuration: self.pagingDuration,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
               self.scrollView.setContentOffset(offset, animated: false)
            }, completion: nil
        )
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        refreshTheme()
    }
    
    @discardableResult internal func refreshBrand() async -> CourierBrand? {
        do {
            if let brandId = self.theme.brandId {
                let res = try await Courier.shared.client?.brands.getBrand(brandId: brandId)
                self.theme.brand = res?.data.brand
                self.refreshTheme()
                return res?.data.brand
            }
        } catch {
            await Courier.shared.client?.log(error.localizedDescription)
        }
        return nil
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTheme(isDarkMode: traitCollection.userInterfaceStyle == .dark)
        }
    }
    
    private func setTheme(isDarkMode: Bool) {
        theme = isDarkMode ? darkTheme : lightTheme
        refreshTheme()
    }
    
    private func refreshTheme() {
        courierBar.setColors(with: superview?.backgroundColor)
        courierBar.setTheme(self.theme)
        tabView.setTheme(self.theme)
        getPages().forEach { page in
            page.page.setTheme(self.theme)
        }
    }
    
    deinit {
        inboxListener?.remove()
    }
    
}
