//
//  KeyboardInfo.swift
//  KeyboardController
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import UIKit

/// Struct representation of keyboard notification `userInfo`.
public struct KeyboardInfo {

    // MARK: - Properties

    private let userInfo: [AnyHashable: Any]

    // MARK: - Lifecycle
    public init?(notification: Notification) {
        guard let userInfo = notification.userInfo else { return nil }
        self.userInfo = userInfo
    }

    private init() {
        self.userInfo = [:]
    }

    // MARK: - Public properties

    /// Identifies the starting frame rectangle of the keyboard in screen coordinates.
    /// The frame rectangle reflects the current orientation of the device.
    public var beginFrame: CGRect {
        return (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }

    /// Identifies the ending frame rectangle of the keyboard in screen coordinates.
    /// The frame rectangle reflects the current orientation of the device.
    public var endFrame: CGRect {
        return (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }

    /// Identifies the distance by Y axis between starting and ending frames origins.
    public var frameHeightDelta: CGFloat {
        return beginFrame.origin.y - endFrame.origin.y
    }

    /// Identifies whether the keyboard belongs to the current app.
    ///
    /// The value of this key is YES for the app that caused the keyboard to appear and NO for any other apps.
    /// - note: With multitasking on iPad, all visible apps are notified when the keyboard appears and disappears.
    public var keyboardIsLocal: Bool {
        return (userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue ?? true
    }

    /// Identifies the duration of the animation in seconds.
    public var animationDuration: Double {
        return (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
    }

    /// Defines how the keyboard will be animated onto or off the screen.
    public var animationCurve: UIView.AnimationCurve {
        guard let value = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return .easeInOut }
        return UIView.AnimationCurve(rawValue: value) ?? .easeInOut
    }

    /// Representation of `animationCurve`.
    public var animationOptions: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
    }

    // MARK: - Public methods

    /// Animates view with `animations` closure and then executes `completion`.
    ///
    /// - Parameters:
    ///   - animations: View animations to be performed.
    ///   - completion: Called after the animation is finished.
    public func animateView(_ animations: @escaping (() -> Void), completion: ((_ finished: Bool) -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: animationOptions,
                       animations: animations,
                       completion: completion
        )}

    /// Calculates keyboard height form a given `keyboardFrame` considering
    /// bottom Safe Area inset of the given `view`.
    ///
    /// - Parameters:
    ///   - keyboardFrame: Keyboard frame in screen coordinates.
    ///   - view: View below keyboard.
    /// - Returns: Keyboard height adjusted to Safe Area.
    @available(iOS 11.0, *)
    public func keyboardHeightInSafeArea(keyboardFrame: CGRect, inside view: UIView) -> CGFloat {
       return keyboardFrame.height - view.safeAreaInsets.bottom
    }
}

// MARK: - Factory methods
public extension KeyboardInfo {
    static var defaultInfo: KeyboardInfo {
        return KeyboardInfo()
    }
}

// MARK: - CustomStringConvertible
extension KeyboardInfo: CustomStringConvertible {
    public var description: String {
        let components = [
            "KeyboardInfo:",
            "beginFrame: \(beginFrame)",
            "endFrame: \(endFrame)",
            "frameHeightDelta: \(frameHeightDelta)",
            "keyboardIsLocal: \(keyboardIsLocal)",
            "animationDuration: \(animationDuration)",
            "animationCurve: \(animationCurve)"

        ]
        return components.joined(separator: "\n")
    }
}
