//
//  KeyboardInfoViewController.swift
//  KeyboardController
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import UIKit
import KeyboardController

final class KeyboardInfoViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var keyboardInfoLabel: UILabel!

    // MARK: - Constraints

    @IBOutlet private weak var adjustableViewBottom: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    // MARK: - Notifications

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        keyboardInfoLabel.text = String(describing: keyboardInfo)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        adjustableViewBottom.constant = keyboardInfo.frameHeightDelta - view.safeAreaInsets.bottom
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardInfo = KeyboardInfo(notification: notification) else { return }
        adjustableViewBottom.constant = 0.0
        keyboardInfo.animateView({ [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}

// MARK: - UITextFieldDelegate
extension KeyboardInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
