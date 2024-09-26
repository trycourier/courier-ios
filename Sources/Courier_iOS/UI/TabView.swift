//
//  TabView.swift
//  Courier_iOS
//
//  Created by Michael Miller on 9/26/24.
//

import UIKit

internal struct Page {
    let title: String
    let page: UIView
}

internal class TabView: UIView, UIScrollViewDelegate {
    
    let pages: [Page]
    let scrollView: UIScrollView
    let onTabSelected: (Int) -> Void
    
    private let tabsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemYellow
        return view
    }()
    
    private var tabViews: [Tab] = []
    
    public init(pages: [Page], scrollView: UIScrollView, onTabSelected: @escaping (Int) -> Void) {
        self.pages = pages
        self.scrollView = scrollView
        self.onTabSelected = onTabSelected
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.pages = []
        self.scrollView = UIScrollView()
        self.onTabSelected = { _ in }
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.pages = []
        self.scrollView = UIScrollView()
        self.onTabSelected = { _ in }
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        self.scrollView.delegate = self
        
        // Add stack view for tabs
        addSubview(tabsStackView)
        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: topAnchor),
            tabsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStackView.heightAnchor.constraint(equalToConstant: 44) // Fixed height for tabs
        ])
        
        addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 2),
            indicatorView.bottomAnchor.constraint(equalTo: tabsStackView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalTo: tabsStackView.widthAnchor, multiplier: 1.0 / CGFloat(pages.count))
        ])
        
        // Initialize tabs and add them to the stack view
        for (index, page) in pages.enumerated() {
            let tab = Tab(title: page.title) { [weak self] in
                self?.onTabSelected(index)
            }
            tabsStackView.addArrangedSubview(tab)
            tabViews.append(tab)
        }
        
        updateTabsAppearance()
        
    }
    
    // MARK: ScrollView Delegates
    
    private func getCurrentPageIndex() -> Int {
        let pageWidth = scrollView.frame.size.width
            
        // Check to avoid division by zero
        guard pageWidth > 0 else {
            return 0
        }
        
        let fractionalPageIndex = scrollView.contentOffset.x / pageWidth
        return Int(fractionalPageIndex.rounded())
    }
    
    private func updateTabsAppearance() {
        for (index, tab) in tabViews.enumerated() {
            tab.isSelected = index == getCurrentPageIndex()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let fullDistance = scrollView.contentSize.width - scrollView.frame.width
        let adjustedOffset = scrollView.contentOffset.x / fullDistance
        let singleItemWidth = bounds.width / CGFloat(pages.count)
        let fullAdjustableDistance = bounds.width - singleItemWidth
        let x = fullAdjustableDistance * adjustedOffset
        
        // Update the UI
        indicatorView.frame.origin.x = x
        updateTabsAppearance()
        
    }
    
//    func sync(with scrollView: UIScrollView) {
//        
//        // Get the current content offset
//        let currentOffsetX = scrollView.contentOffset.x
//
//        // Calculate the total scrollable width
//        let totalScrollableWidth = scrollView.contentSize.width - scrollView.frame.size.width
//        
//        // Calculate the percentage offset
//        let percentageOffset: CGFloat
//        if totalScrollableWidth > 0 {
//            percentageOffset = currentOffsetX / totalScrollableWidth
//        } else {
//            percentageOffset = 0
//        }
//
//        // Calculate the new leading position for the indicator
//        let tabWidth = self.bounds.width / CGFloat(tabViews.count)
//        let newLeadingPosition = tabWidth * percentageOffset * CGFloat(tabViews.count)
//
//        // Update the leading constraint of the indicator
//        indicatorView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.deactivate(indicatorView.constraints) // Deactivate previous constraints
//        indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: newLeadingPosition).isActive = true
//
//        // Update the layout immediately
//        self.layoutIfNeeded()
//        
//    }
    
}

internal class Tab: UIView {
    
    let title: String
    let onTapped: () -> Void
    
    var isSelected = false {
        didSet {
            backgroundColor = isSelected ? .systemBlue : .clear
            titleLabel.textColor = isSelected ? .white : .black
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public init(title: String, onTapped: @escaping () -> Void) {
        self.title = title
        self.onTapped = onTapped
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        self.title = ""
        self.onTapped = {}
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.title = ""
        self.onTapped = {}
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        titleLabel.text = title
        
        // Set constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Add tap gesture to handle tab selection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func tabTapped() {
        onTapped()
    }
}
