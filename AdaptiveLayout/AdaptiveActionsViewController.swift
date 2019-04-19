//
//  Created by Brian Coyner on 7/8/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation
import UIKit

/// This view controller's `view` is embedded in a `UIBarButtonItem` as a custom view.
/// The view adapts to the current horizontal size class.
///
/// - If the horizontal size class is `compact`, then
///   - the view shows a `UIButton`
///   - tapping the button displays an alert controller as an action sheet
///   - there's a `UIAlertAction` for each `AdaptiveAction`
///   - tapping an alert action executes the "bound" `AdaptiveAction`
///
/// - If the horizontal size class is `regular`, then
///   - the view shows a `UISegmentedControl`
///   - there's a segment for each `AdaptiveAction`
///   - tapping a segment executes the "bound" `AdaptiveAction`
///
/// See the `traitCollectionDidChange(_:)` for the main point of this demo code.
final class AdaptiveActionsViewController: UIViewController {

    /// A private "state" enum helps manage the appropriate subviews.
    fileprivate enum HorizontalSizeClassState {
        case compact(UIButton)
        case regular(UISegmentedControl)
    }

    fileprivate let actions: [AdaptiveAction]
    fileprivate var selectedActionIndex: Int
    fileprivate var sizeClassState: HorizontalSizeClassState

    init(actions: [AdaptiveAction]) {
        self.actions = actions
        self.selectedActionIndex = 0
        self.sizeClassState = .compact(UIButton(type: .system))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdaptiveActionsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disabling this property ensures that the view properly lays out in the owning toolbar.
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension AdaptiveActionsViewController {

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard newCollection.horizontalSizeClass != traitCollection.horizontalSizeClass else {
            return
        }

        // Note: In this case, the presented view controller may be an alert controller showing
        // the available filter actions. If the horizontal size class changes, then we need to
        // dismiss the alert controller.
        //
        // Here's the scenario:
        // - the app is currently horizontally `compact`
        // - the user opens the "action sheet"
        // - while the "action sheet" is presented, the horizontal size class changes to `regular`
        //   - rotation (possible on an iPhone Plus)
        //   - side-by-side view resizing (possible on an iPad)
        // - upon changing to `regular`, the "action sheet" is dismissed
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension AdaptiveActionsViewController {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass else {
            return
        }

        view.subviews.forEach { $0.removeFromSuperview() }

        switch traitCollection.horizontalSizeClass {
        case .compact:
            transitionToCompactState()
        case .regular, .unspecified:
            transitionToRegularState()
        @unknown default:
            transitionToRegularState()
        }
    }
}

extension AdaptiveActionsViewController {

    @objc
    fileprivate func userChangedSelectedSegment(_ segmentedControl: UISegmentedControl) {
        selectedActionIndex = segmentedControl.selectedSegmentIndex
        actions[selectedActionIndex].action()
    }
}

extension AdaptiveActionsViewController {

    @objc
    fileprivate func userTappedActionButton(_ button: UIButton) {
        let alertController = UIAlertController(title: LocalizedStrings.Alert.filterByTitleText, message: nil, preferredStyle: .actionSheet)

        for current in actions.enumerated() {
            let action = UIAlertAction(title: current.element.title, style: .default, handler: { [unowned self] _ in
                self.selectedActionIndex = current.offset
                current.element.action()

                //
                // The desire is to change the button's text without animating.
                // By default, a `.system` button animates when the text changes.
                // This disables that default animation.
                //
                UIView.performWithoutAnimation {
                    button.setTitle(self.makeButtonTitle(for: current.element), for: .normal)
                    button.layoutIfNeeded()
                }
            })

            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: LocalizedStrings.AlertAction.cancelTitleText, style: .cancel, handler: nil))

        sizeClassState = .compact(button)
        present(alertController, animated: true, completion: nil)
    }
}

extension AdaptiveActionsViewController {

    fileprivate func transitionToCompactState() {
        let button = makeButton(withTitle: makeButtonTitle(for: actions[selectedActionIndex]))
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        sizeClassState = .compact(button)
    }

    fileprivate func transitionToRegularState() {
        let segmentedControl = makeSegmentedControl(with: actions)

        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        segmentedControl.selectedSegmentIndex = selectedActionIndex
        actions[selectedActionIndex].action()

        sizeClassState = .regular(segmentedControl)
    }
}

extension AdaptiveActionsViewController {

    fileprivate func makeButton(withTitle title: String?) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitle(title, for: .normal)

        button.addTarget(self, action: #selector(userTappedActionButton), for: .primaryActionTriggered)

        return button
    }

    fileprivate func makeButtonTitle(for action: AdaptiveAction) -> String {
        return LocalizedStrings.Button.filterButtonTitleText(for: action.title)
    }
}

extension AdaptiveActionsViewController {

    fileprivate func makeSegmentedControl(with actions: [AdaptiveAction]) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: actions.map { $0.title })
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.addTarget(self, action: #selector(userChangedSelectedSegment), for: .valueChanged)

        return segmentedControl
    }
}

extension AdaptiveActionsViewController {

    fileprivate enum LocalizedStrings {

        enum Alert {
            static var filterByTitleText: String {
                return NSLocalizedString("alert.show-filter-by-title.text", comment: "")
            }
        }

        enum AlertAction {
            static var cancelTitleText: String {
                return NSLocalizedString("alert-action.cancel-title.text", comment: "")
            }
        }

        enum Button {
            static func filterButtonTitleText(for action: String) -> String {
                let formatString = NSLocalizedString("toolbar.filtered-by-button.title %@", comment: "")
                return String(format: formatString, action)
            }
        }
    }
}
