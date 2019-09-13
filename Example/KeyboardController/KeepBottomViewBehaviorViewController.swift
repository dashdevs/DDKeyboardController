//
//  KeepBottomViewBehaviorViewController.swift
//  KeyboardController_Example
//
//  Created by Igor Kulik on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import KeyboardController

final class KeepBottomViewBehaviorViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var viewInFocus: UIView!
    
    // MARK: - Constraints

    @IBOutlet private weak var contentHeight: NSLayoutConstraint!

    // MARK: - Properties

    private lazy var keyboardController: KeyboardController = { [unowned self] in
        return KeyboardController(view: self.view, constraint: self.contentHeight, adjustmentType: .keepBottomViewInFocus(view: self.viewInFocus, bottomOffset: 20.0))
        }()

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardController.addKeyboardNotificationObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController.removeKeyboardNotificationObservers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        infoLabel.text = """
        content height: \(contentView.frame.height)
        height constraint: \(contentHeight.constant)
        """
    }
}

// MARK: - UITextFieldDelegate
extension KeepBottomViewBehaviorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
