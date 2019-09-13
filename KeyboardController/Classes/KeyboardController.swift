//
//  KeyboardController.swift
//  KeyboardController
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import UIKit

/// Helper class that adjsusts the view by its height constraint
/// when keyboard frame changes.
final class KeyboardController {

    typealias DeltaCalculationClosure = (KeyboardInfo) -> CGFloat

    /// Defines how the view and its subviews adjust to keyboard frame changes.
    ///
    /// - contentViewHeight: Overall content height is changed by keyboard height delta.
    /// - keepBottomViewInFocus: Overall content height is changed in order to always keep distance => `bottomOffset` between specified `view` content bottom.
    /// - custom: Non-typical content adjustment behavior, defined by `calculationClosure`.
    enum ContentAdjustmentType {
        case contentViewHeight
        case keepBottomViewInFocus(view: UIView, bottomOffset: CGFloat)
        case custom(calculationClosure: DeltaCalculationClosure)
    }

    // MARK: - Properties

    /// Parent view to be animated when keyboard frame changes.
    private unowned let view: UIView

    /// Height constraint of parent view.
    /// (Recommended to use `view.height == superview.height`)
    private unowned let contentDeltaHeightConstraint: NSLayoutConstraint

    /// Content behavior whe keyboard frame changes.
    private let adjustmentType: ContentAdjustmentType

    // MARK: - Lifecycle

    /// Creates a ready-to-use instance with the given configuration.
    ///
    /// - Parameters:
    ///   - view: Parent view to be animated when keyboard frame changes.
    ///   - constraint: Height constraint of parent view.
    ///   - adjustmentType: Content behavior whe keyboard frame changes.
    init(view: UIView, constraint: NSLayoutConstraint, adjustmentType: ContentAdjustmentType) {
        self.view = view
        self.contentDeltaHeightConstraint = constraint
        self.adjustmentType = adjustmentType
    }

    // MARK: - Public methods

    @objc func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillHide, name: .UIKeyboardWillHide, object: nil)
    }

    @objc func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    // MARK: - Private methods

    private func calculateDelta(for keyboardInfo: KeyboardInfo) -> CGFloat? {
        var delta: CGFloat
        switch adjustmentType {
        case .contentViewHeight:
            delta = -(keyboardInfo.endFrame.height - view.safeAreaInsets.bottom)
        case .keepBottomViewInFocus(let bottomView, let offset):
            let y = view.safeAreaInsets.top + bottomView.frame.maxY + offset
            let currentDelta = contentDeltaHeightConstraint.constant
            delta = currentDelta - (y - keyboardInfo.endFrame.origin.y)
            if delta > 0 { delta = 0 }
        case .custom(let calculationClosure):
            delta = calculationClosure(keyboardInfo)
        }
        return delta
    }

    // MARK: - Notifications

    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification),
            let delta = calculateDelta(for: keyboardInfo) else {
                return
        }
        contentDeltaHeightConstraint.constant = delta
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        contentDeltaHeightConstraint.constant = 0.0
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}

fileprivate extension Selector {
    static let keyboardWillShow = #selector(KeyboardController.keyboardWillShow(_:))
    static let keyboardWillHide = #selector(KeyboardController.keyboardWillHide(_:))
}
