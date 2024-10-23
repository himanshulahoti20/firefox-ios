// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import ComponentLibrary
import UIKit
import Shared
import Redux

struct SearchEngineSection: SectionData {
    typealias E = SearchEngineSelectionCellModel

    var elementData: [SearchEngineSelectionCellModel]
}

struct SearchEngineSelectionCellModel: GeneralImageTableViewCellModel {
    let title: String
    let description: String?
    let image: UIImage
    var isEnabled = true
    var isActive = false
    var hasDisclosure = false

    // Accessibility
    let a11yLabel: String
    let a11yHint: String?
    let a11yId: String

    var action: (() -> Void)?

    init(title: String) {
        // FIXME Temporary placeholder initialization
        self.title = title
        self.description = nil
        self.image = UIImage(named: "globeLarge")!
        self.a11yLabel = ""
        self.a11yHint = ""
        self.a11yId = ""
        self.action =  nil
    }
}

class SearchEngineSelectionCell: GeneralImageTableViewCell<SearchEngineSelectionCellModel> {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureCellWith(model: SearchEngineSelectionCellModel) {
        super.configureCellWith(model: model)
        // TODO additional customization
    }
}

class SearchEngineSelectionViewController: UIViewController,
                                           UISheetPresentationControllerDelegate,
                                           UIPopoverPresentationControllerDelegate,
                                           Themeable,
                                           GeneralTableViewDelegate {
    typealias S = SearchEngineSection // For GeneralTableViewDataDelegate conformance

    // MARK: - Properties
    var notificationCenter: NotificationProtocol
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var currentWindowUUID: UUID? { return windowUUID }

    weak var coordinator: SearchEngineSelectionCoordinator?
    private let windowUUID: WindowUUID
    private let logger: Logger

    // MARK: - UI/UX elements
    private var tableView: GeneralTableView<
        SearchEngineSection,
        SearchEngineSelectionCell,
        SearchEngineSelectionViewController
    > = .build()

    // MARK: - Initializers and Lifecycle

    init(
        windowUUID: WindowUUID,
        notificationCenter: NotificationProtocol = NotificationCenter.default,
        themeManager: ThemeManager = AppContainer.shared.resolve(),
        logger: Logger = DefaultLogger.shared
    ) {
        self.windowUUID = windowUUID
        self.notificationCenter = notificationCenter
        self.themeManager = themeManager
        self.logger = logger
        super.init(nibName: nil, bundle: nil)

        tableView.delegate = self

        // TODO Additional setup to come
        // ...
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sheetPresentationController?.delegate = self // For non-iPad setup
        popoverPresentationController?.delegate = self // For iPad setup

        setupView()
        listenForThemeChange(view)

        // FIXME Mock data for testing. Hookups to search engines to come later.
        let fakeData: [SearchEngineSection] = [
            SearchEngineSection(elementData: [
                SearchEngineSelectionCellModel(title: "Search engine 1"),
                SearchEngineSelectionCellModel(title: "Search engine 2"),
                SearchEngineSelectionCellModel(title: "Search engine 3")
            ]),
            SearchEngineSection(elementData: [
                SearchEngineSelectionCellModel(title: "Search Settings"), // TODO include disclosure?
            ])
        ]
        tableView.reloadTableView(with: fakeData)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyTheme()
    }

    // MARK: - UI / UX

    private func setupView() {
        view.addSubviews(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12), // TODO Temporary constant
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Theme

    func applyTheme() {
        let theme = themeManager.getCurrentTheme(for: windowUUID)

        view.backgroundColor = theme.colors.layer3
        tableView.applyTheme(theme: theme)
    }

    // MARK: - UISheetPresentationControllerDelegate inheriting UIAdaptivePresentationControllerDelegate

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator?.dismissModal(animated: true)
    }

    // MARK: - Navigation

    @objc
    func didTapOpenSettings(sender: UIButton) {
        coordinator?.navigateToSearchSettings(animated: true)
    }

    // MARK: - GeneralTableViewDataDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView, inScrollViewWithTopPadding topPadding: CGFloat) {
        // TODO scrollViewDidScroll
    }
}
