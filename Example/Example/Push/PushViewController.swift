//
//  PushViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 11/17/22.
//

import UIKit
import Courier_iOS

class PushViewController: UIViewController, UICollectionViewDelegate {

    private enum Section: Int, CaseIterable {
        case permission, tokens

        var title: String {
            switch self {
            case .permission: return "Notifications"
            case .tokens: return "Tokens"
            }
        }

        var footer: String? {
            switch self {
            case .permission: return nil
            case .tokens: return "Tap a token to copy it."
            }
        }
    }

    private enum Item: Hashable {
        case permissionStatus
        case requestPermission
        case token(Int)
    }

    private var permissionStatus: UNAuthorizationStatus = .notDetermined
    private var tokens = [("APNs Token", ""), ("FCM Token", "")]

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Push"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Refresh",
            image: UIImage(systemName: "arrow.clockwise"),
            primaryAction: UIAction { [weak self] _ in
                self?.refresh()
            }
        )

        configureCollectionView()
        refresh()
    }

    private func configureCollectionView() {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = Section.allCases[sectionIndex]
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            configuration.footerMode = section.footer == nil ? .none : .supplementary
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)

        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in self?.refresh() }, for: .valueChanged)
        collectionView.refreshControl = refreshControl

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [unowned self] cell, _, item in
            switch item {
            case .permissionStatus:
                var content = UIListContentConfiguration.valueCell()
                content.text = "Permission"
                content.secondaryText = permissionStatus.label
                content.image = UIImage(systemName: permissionStatus.systemImage)
                content.imageProperties.tintColor = permissionStatus.tint
                cell.contentConfiguration = content
                cell.accessories = []
            case .requestPermission:
                var content = UIListContentConfiguration.cell()
                content.text = "Request Permission"
                content.textProperties.color = .tintColor
                cell.contentConfiguration = content
                cell.accessories = []
                cell.accessibilityTraits = .button
            case .token(let index):
                let (title, value) = tokens[index]
                var content = UIListContentConfiguration.subtitleCell()
                content.text = title
                content.textProperties.font = .preferredFont(forTextStyle: .footnote)
                content.textProperties.color = .secondaryLabel
                content.secondaryText = value.isEmpty ? "Not registered" : value
                content.secondaryTextProperties.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .regular)
                content.secondaryTextProperties.color = value.isEmpty ? .tertiaryLabel : .label
                content.textToSecondaryTextVerticalPadding = 4
                cell.contentConfiguration = content
                cell.accessories = value.isEmpty ? [] : [.customView(configuration: .copyIndicator)]
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { header, _, indexPath in
            var content = UIListContentConfiguration.header()
            content.text = Section.allCases[indexPath.section].title
            header.contentConfiguration = content
        }

        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) { footer, _, indexPath in
            var content = UIListContentConfiguration.footer()
            content.text = Section.allCases[indexPath.section].footer
            footer.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([.permissionStatus, .requestPermission], toSection: .permission)
        snapshot.appendItems(tokens.indices.map { .token($0) }, toSection: .tokens)
        dataSource.apply(snapshot, animatingDifferences: false)

    }

    private func refresh() {
        Task {
            permissionStatus = (try? await Courier.getNotificationPermissionStatus()) ?? .notDetermined
            tokens[0].1 = await Courier.shared.getToken(for: .apn) ?? ""
            tokens[1].1 = await Courier.shared.getToken(for: .firebaseFcm) ?? ""
            reloadItems()
            collectionView.refreshControl?.endRefreshing()
        }
    }

    private func requestPermission() {
        Task {
            permissionStatus = (try? await Courier.requestNotificationPermission()) ?? permissionStatus
            refresh()
        }
    }

    private func reloadItems() {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        switch dataSource.itemIdentifier(for: indexPath) {
        case .requestPermission:
            requestPermission()
        case .token(let index):
            let (title, value) = tokens[index]
            guard !value.isEmpty else { return }
            UIPasteboard.general.string = value
            showToast("\(title) copied")
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return dataSource.itemIdentifier(for: indexPath) != .permissionStatus
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, case .token(let index) = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let (title, value) = tokens[index]
        guard !value.isEmpty else { return nil }
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                    UIPasteboard.general.string = value
                    self?.showToast("\(title) copied")
                },
                UIAction(title: "View", image: UIImage(systemName: "text.magnifyingglass")) { [weak self] _ in
                    self?.showCode(title: title, code: value)
                }
            ])
        })
    }

}

extension UNAuthorizationStatus {

    var label: String {
        switch self {
        case .authorized: return "Allowed"
        case .denied: return "Denied"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        case .notDetermined: return "Not requested"
        @unknown default: return "Unknown"
        }
    }

    var systemImage: String {
        switch self {
        case .authorized, .provisional, .ephemeral: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    var tint: UIColor {
        switch self {
        case .authorized, .provisional, .ephemeral: return .systemGreen
        case .denied: return .systemRed
        default: return .systemGray
        }
    }

}

extension UICellAccessory.CustomViewConfiguration {

    // A quiet hint that tapping the row copies its value
    static var copyIndicator: UICellAccessory.CustomViewConfiguration {
        let imageView = UIImageView(image: UIImage(systemName: "doc.on.doc"))
        imageView.tintColor = .tertiaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote)
        return UICellAccessory.CustomViewConfiguration(customView: imageView, placement: .trailing(), reservedLayoutWidth: .actual)
    }

}
