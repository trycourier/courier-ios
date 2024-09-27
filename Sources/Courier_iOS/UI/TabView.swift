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
    
    private let border: UIView = {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        return border
    }()
    
    let pages: [Page]
    let scrollView: UIScrollView
    let onTabSelected: (Int) -> Void
    private var theme: CourierInboxTheme? = nil
    
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
        return view
    }()
    
    private(set) var tabs: [Tab] = []
    
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
        
        self.backgroundColor = .systemBackground
        self.scrollView.delegate = self
        
        addSubview(tabsStackView)
        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: topAnchor),
            tabsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStackView.heightAnchor.constraint(equalToConstant: Theme.Bar.barHeight)
        ])
        
        // Initialize tabs and add them to the stack view
        for (index, page) in pages.enumerated() {
            let tab = Tab(title: page.title) { [weak self] in
                self?.onTabSelected(index)
            }
            tabsStackView.addArrangedSubview(tab)
            tabs.append(tab)
        }
        
        addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 3),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(pages.count))
        ])
        
        addSubview(border)
        
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 0.5),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        setSelectedTab()
        
    }
    
    func setTheme(_ theme: CourierInboxTheme) {
        self.theme = theme
        self.border.backgroundColor = theme.cellStyle.separatorColor ?? .separator
        self.indicatorView.backgroundColor = theme.indicatorColor
        self.tabsStackView.subviews.forEach { view in
            if let view = view as? Tab {
                view.setTheme(theme: theme)
            }
        }
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
    
    private func setSelectedTab() {
        for (index, tab) in tabs.enumerated() {
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
        setSelectedTab()
        
    }
    
}

internal class Tab: UIView {
    
    let title: String
    let onTapped: () -> Void
    private var theme: CourierInboxTheme? = nil
    
    var isSelected = false {
        didSet {
            refresh()
        }
    }
    
    var badge: Int? = nil {
        didSet {
            refresh()
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private func refresh() {
        titleLabel.textColor = isSelected ? theme?.tabStyle.selected.color : theme?.tabStyle.unselected.color
        titleLabel.font = isSelected ? theme?.tabStyle.selected.font : theme?.tabStyle.unselected.font
        
        if let value = getBadgeValue(value: self.badge ?? 0) {
            badgeLabel.text = value
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
        
        titleLabel.text = title
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func getBadgeValue(value: Int) -> String? {
        if (value <= 0) {
            return nil
        } else if (value >= 99) {
            return "99+"
        } else {
            return "\(value)"
        }
    }
    
    func setTheme(theme: CourierInboxTheme) {
        self.theme = theme
        refresh()
    }
    
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
        backgroundColor = .systemBackground
        
        // Add stackView, titleLabel, and badgeLabel
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(badgeLabel)

        // Set constraints for stackView to be centered in the parent view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
        
        titleLabel.text = title
        
        addGestureRecognizers()
        
    }
    
    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped))
        tapGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapGesture)
    }
    
    private func animateOpacity(to alpha: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.alpha = alpha
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateOpacity(to: 0.5)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateOpacity(to: 1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateOpacity(to: 1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        animateOpacity(to: 1)
    }
    
    @objc private func tabTapped() {
        onTapped()
    }
    
}

internal class TabBadge: UIView {
    
    let title: String
    private var theme: CourierInboxTheme? = nil
    
    var isSelected = false {
        didSet {
            refresh()
        }
    }
    
    private func refresh() {
        titleLabel.textColor = isSelected ? theme?.tabStyle.selected.color : theme?.tabStyle.unselected.color
        titleLabel.font = isSelected ? theme?.tabStyle.selected.font : theme?.tabStyle.unselected.font
    }
    
    func setTheme(theme: CourierInboxTheme) {
        self.theme = theme
        refresh()
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        self.title = ""
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.title = ""
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        // Create the label with padding
        let titleLabel = PaddedLabel()
        titleLabel.text = title
        titleLabel.backgroundColor = .red
        titleLabel.textAlignment = .center // Optional: Center the text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.cornerRadius = 10 // Set the corner radius
        titleLabel.layer.masksToBounds = true // Clip the corners

        // Add the label as a subview
        addSubview(titleLabel)

        // Set constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
    }
    
}

class PaddedLabel: UILabel {
    
    var padding: UIEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)

    override func drawText(in rect: CGRect) {
        let paddedRect = rect.inset(by: padding)
        super.drawText(in: paddedRect)
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicSize = super.intrinsicContentSize
        let paddedWidth = intrinsicSize.width + padding.left + padding.right
        let paddedHeight = intrinsicSize.height + padding.top + padding.bottom
        return CGSize(width: paddedWidth, height: paddedHeight)
    }
    
}
