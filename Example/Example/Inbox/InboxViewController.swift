import UIKit
import Courier_iOS

class InboxViewController: SegmentedPagesViewController {

    private var inboxListener: CourierInboxListener? = nil

    private lazy var readAllButton = UIBarButtonItem(
        title: "Read All",
        image: UIImage(systemName: "envelope.open"),
        primaryAction: UIAction { [weak self] _ in
            self?.readAll()
        }
    )

    override func makePages() -> [(title: String, viewController: UIViewController)] {
        return [
            ("Default", PrebuiltInboxViewController()),
            ("Styled", StyledInboxViewController()),
            ("Custom", CustomInboxViewController())
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = readAllButton
        readAllButton.isEnabled = false

        // Only offer Read All when there's something unread
        Task { [weak self] in
            let listener = await Courier.shared.addInboxListener(
                onUnreadCountChanged: { [weak self] count in
                    self?.readAllButton.isEnabled = count > 0
                }
            )
            self?.inboxListener = listener
        }

    }

    private func readAll() {

        Task {

            do {
                try await Courier.shared.readAllInboxMessages()
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }

        }

    }

    deinit {
        inboxListener?.remove()
    }

}
