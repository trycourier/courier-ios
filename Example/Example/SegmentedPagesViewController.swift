//
//  SegmentedPagesViewController.swift
//  Example
//
//  Created by Michael Miller on 11/3/26.
//

import UIKit

// Switches between example screens with a segmented control in the navigation bar.
// Subclasses supply the pages.
class SegmentedPagesViewController: UIViewController {

    private var pages: [(title: String, viewController: UIViewController)] = []
    private var currentPage: UIViewController?
    private let segmentedControl = UISegmentedControl()

    func makePages() -> [(title: String, viewController: UIViewController)] {
        return []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        pages = makePages()

        for (index, page) in pages.enumerated() {
            let action = UIAction(title: page.title) { [weak self] _ in
                self?.showPage(at: index)
            }
            segmentedControl.insertSegment(action: action, at: index, animated: false)
        }

        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl

        showPage(at: 0)

    }

    private func showPage(at index: Int) {

        let page = pages[index].viewController
        guard page !== currentPage else { return }

        currentPage?.willMove(toParent: nil)
        currentPage?.view.removeFromSuperview()
        currentPage?.removeFromParent()

        addChild(page)
        page.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(page.view)

        // The SDK views draw their own headers, so keep them clear of the bars
        NSLayoutConstraint.activate([
            page.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            page.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            page.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            page.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        page.didMove(toParent: self)
        currentPage = page

    }

}
