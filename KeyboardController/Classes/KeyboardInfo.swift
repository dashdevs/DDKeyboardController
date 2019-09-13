//
//  KeyboardInfo.swift
//  KeyboardController
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// Struct representation of keyboard notification `userInfo`.
public final class KeyboardInfo: NSObject {

    // MARK: - Properties

    private let userInfo: [AnyHashable: Any]

    // MARK: - Lifecycle
    init?(notification: Notification) {
        guard let userInfo = notification.userInfo else { return nil }
        self.userInfo = userInfo
    }

    private override init() {
        self.userInfo = [:]
        super.init()
    }

    // MARK: - Public properties

    /// Identifies the starting frame rectangle of the keyboard in screen coordinates.
    /// The frame rectangle reflects the current orientation of the device.
    var beginFrame: CGRect {
        return (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }

    /// Identifies the ending frame rectangle of the keyboard in screen coordinates.
    /// The frame rectangle reflects the current orientation of the device.
    var endFrame: CGRect {
        return (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }

    /// Identifies the distance by Y axis between starting and ending frames origins.
    var frameHeightDelta: CGFloat {
        return beginFrame.origin.y - endFrame.origin.y
    }

    /// Identifies the duration of the animation in seconds.
    var animationDuration: Double {
        return (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
    }

    /// Defines how the keyboard will be animated onto or off the screen.
    var animationCurve: UIView.AnimationCurve {
        guard let value = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int else { return .easeInOut }
        return UIView.AnimationCurve(rawValue: value) ?? .easeInOut
    }

    /// Representation of `animationCurve`.
    var animationOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
    }

    // MARK: - Public methods

    /// Animates view with `animations` closure and then executes `completion`.
    ///
    /// - Parameters:
    ///   - animations: View animations to be performed.
    ///   - completion: Called after the animation is finished.
    func animateView(_ animations: @escaping (() -> Void), completion: ((_ finished: Bool) -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: animationOptions,
                       animations: animations,
                       completion: completion
        )}
}

// MARK: - Factory methods
public extension KeyboardInfo {
    static var defaultInfo: KeyboardInfo {
        return KeyboardInfo()
    }
}

