//
//  PreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 1/9/24.
//

import UIKit
import Courier_iOS

class PreferencesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var segmentedControl: UISegmentedControl!
    var isScrollingFromSegmentedControl = false
    
    private lazy var pages: [(String, UIViewController)] = [
        ("Default", PrebuiltPreferencesViewController()),
        ("Styled", StyledPreferencesViewController()),
        ("Custom", CustomPreferencesViewController(navController: self.navigationController!))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        // Add segmented control
        segmentedControl = UISegmentedControl(items: pages.map { $0.0 })
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        // Apply constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        isScrollingFromSegmentedControl = true
                
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if selectedSegmentIndex < pages.map({ $0.1 }).count {
            let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        // Reset flag after changing the segment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isScrollingFromSegmentedControl = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.map { $0.1 }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.identifier, for: indexPath) as! ContentCollectionViewCell
        
        // Embed the view controller in the cell
        let viewController = pages.map { $0.1 }[indexPath.item]
        cell.embeddedViewController = viewController
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrollingFromSegmentedControl else { return }
        
        let xOffset = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let collectionViewWidth = scrollView.frame.size.width
        
        // Check if contentWidth or collectionViewWidth is zero to avoid division by zero
        guard contentWidth > 0, collectionViewWidth > 0 else { return }
        
        // Calculate currentIndex with boundary checks
        var currentIndex = Int((xOffset + collectionViewWidth / 2) / collectionViewWidth)
        currentIndex = max(0, min(pages.map { $0.1 }.count - 1, currentIndex))
        
        if segmentedControl.selectedSegmentIndex != currentIndex {
            segmentedControl.selectedSegmentIndex = currentIndex
        }
    }
    
}
