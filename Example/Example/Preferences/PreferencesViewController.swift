//
//  PreferencesViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 1/9/24.
//

import UIKit
import Courier_iOS

class PreferencesViewController: SegmentedPagesViewController {

    override func makePages() -> [(title: String, viewController: UIViewController)] {
        return [
            ("Default", PrebuiltPreferencesViewController()),
            ("Styled", StyledPreferencesViewController()),
            ("Custom", CustomPreferencesViewController(navController: navigationController!))
        ]
    }

}
