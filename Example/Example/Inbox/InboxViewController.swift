import UIKit
import Courier_iOS

class InboxViewController: SegmentedPagesViewController {

    override func makePages() -> [(title: String, viewController: UIViewController)] {
        return [
            ("Default", PrebuiltInboxViewController()),
            ("Styled", StyledInboxViewController()),
            ("Custom", CustomInboxViewController())
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Read All",
            image: UIImage(systemName: "envelope.open"),
            primaryAction: UIAction { [weak self] _ in
                self?.readAll()
            }
        )

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

}
