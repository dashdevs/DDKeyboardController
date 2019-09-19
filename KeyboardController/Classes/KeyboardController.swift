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
public final class KeyboardController {

    public typealias DeltaCalculationClosure = (KeyboardInfo) -> CGFloat
    public typealias KeyboardNotificationCallback = (KeyboardInfo) -> Void

    /// Defines how the view and its subviews adjust to keyboard frame changes.
    ///
    /// - contentViewHeight: Overall content height is changed by keyboard height delta.
    /// - keepBottomViewInFocus: Overall content height is changed in order to always keep distance => `bottomOffset` between specified `view` content bottom.
    /// - custom: Non-typical content adjustment behavior, defined by `calculationClosure`.
    public enum ContentBehaviorType {
        case contentViewHeight
        case keepBottomViewInFocus(view: UIView, bottomOffset: CGFloat)
        case custom(calculationClosure: DeltaCalculationClosure)
    }

    // MARK: - Properties

    /// Parent view to be animated when keyboard frame changes.
    private unowned let view: UIView

    /// Scroll view that needs to adjust `contentInset` when keyboard frame changes.
    private unowned var scrollView: UIScrollView?

    /// Height constraint of parent view.
    /// (Recommended to use `view.height == superview.height`)
    private unowned let contentDeltaHeightConstraint: NSLayoutConstraint

    /// Content behavior when keyboard frame changes.
    private let behaviorType: ContentBehaviorType

    public var onKeyboardWillShow: KeyboardNotificationCallback?
    public var onKeyboardDidShow: KeyboardNotificationCallback?
    public var onKeyboardWillHide: KeyboardNotificationCallback?
    public var onKeyboardDidHide: KeyboardNotificationCallback?
    public var onKeyboardWillChangeFrame: KeyboardNotificationCallback?
    public var onKeyboardDidChangeFrame: KeyboardNotificationCallback?

    // MARK: - Lifecycle

    /// Creates a ready-to-use instance with the given configuration.
    ///
    /// - Parameters:
    ///   - view: Parent view to be animated when keyboard frame changes.
    ///   - constraint: Height constraint of parent view.
    ///   - behaviorType: Content behavior whe keyboard frame changes.
    ///   - scrollView: Optional scroll view that needs to adjust `contentInset` when keyboard frame changes.
    public init(view: UIView, constraint: NSLayoutConstraint, behaviorType: ContentBehaviorType, scrollView: UIScrollView? = nil) {
        self.view = view
        self.contentDeltaHeightConstraint = constraint
        self.behaviorType = behaviorType
        self.scrollView = scrollView
    }

    // MARK: - Public methods

    public func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardDidShow, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillHide, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardDidHide, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillChangeFrame, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardDidChangeFrame, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    public func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    // MARK: - Private methods

    private func calculateDelta(for keyboardInfo: KeyboardInfo) -> CGFloat? {
        var delta: CGFloat
        switch behaviorType {
        case .contentViewHeight:
            if #available(iOS 11.0, *) {
                delta = -keyboardInfo.keyboardHeightInSafeArea(keyboardFrame: keyboardInfo.endFrame, inside: view)
            } else {
                delta = -keyboardInfo.endFrame.height
            }
        case .keepBottomViewInFocus(let bottomView, let offset):
            var y = bottomView.frame.maxY + offset
            if #available(iOS 11.0, *) {
                y += view.safeAreaInsets.top
            }
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
        let bottomInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomInset = keyboardInfo.keyboardHeightInSafeArea(keyboardFrame: keyboardInfo.endFrame, inside: view)
        } else {
            bottomInset = keyboardInfo.endFrame.height
        }

        scrollView?.contentInset.bottom =  bottomInset
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
        onKeyboardWillShow?(keyboardInfo)
    }

    @objc fileprivate func keyboardDidShow(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        onKeyboardDidShow?(keyboardInfo)
    }

    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        contentDeltaHeightConstraint.constant = 0.0
        scrollView?.contentInset.bottom = 0.0
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
        onKeyboardWillHide?(keyboardInfo)
    }

    @objc fileprivate func keyboardDidHide(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        onKeyboardDidHide?(keyboardInfo)
    }

    @objc fileprivate func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        onKeyboardWillChangeFrame?(keyboardInfo)
    }

    @objc fileprivate func keyboardDidChangeFrame(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        onKeyboardDidChangeFrame?(keyboardInfo)
    }
}

fileprivate extension Selector {
    static let keyboardWillShow = #selector(KeyboardController.keyboardWillShow(_:))
    static let keyboardDidShow = #selector(KeyboardController.keyboardDidShow(_:))
    static let keyboardWillHide = #selector(KeyboardController.keyboardWillHide(_:))
    static let keyboardDidHide = #selector(KeyboardController.keyboardDidHide(_:))
    static let keyboardWillChangeFrame = #selector(KeyboardController.keyboardWillChangeFrame(_:))
    static let keyboardDidChangeFrame = #selector(KeyboardController.keyboardDidChangeFrame(_:))
}
