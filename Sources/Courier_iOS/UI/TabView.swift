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

internal class TabView: UIView {
    
    let pages: [Page]
    let onTabSelected: (Int) -> Void
    
    private let tabsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let pageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var selectedIndex = 0 {
        didSet {
            updateTabsAppearance()
            onTabSelected(selectedIndex)
        }
    }
    
    private var tabViews: [Tab] = []
    
    public init(pages: [Page], onTabSelected: @escaping (Int) -> Void) {
        self.pages = pages
        self.onTabSelected = onTabSelected
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        self.pages = []
        self.onTabSelected = { _ in }
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        self.pages = []
        self.onTabSelected = { _ in }
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Add stack view for tabs
        addSubview(tabsStackView)
        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: topAnchor),
            tabsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabsStackView.heightAnchor.constraint(equalToConstant: 44) // Fixed height for tabs
        ])
        
        // Add page container
        addSubview(pageContainer)
        NSLayoutConstraint.activate([
            pageContainer.topAnchor.constraint(equalTo: tabsStackView.bottomAnchor),
            pageContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Initialize tabs and add them to the stack view
        for (index, page) in pages.enumerated() {
            let tab = Tab(title: page.title) { [weak self] in
                self?.selectedIndex = index
            }
            tabsStackView.addArrangedSubview(tab)
            tabViews.append(tab)
        }
        
        // Initially select the first tab
        updateTabsAppearance()
    }
    
    private func updateTabsAppearance() {
        for (index, tab) in tabViews.enumerated() {
            tab.isSelected = index == selectedIndex
        }
    }
    
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
