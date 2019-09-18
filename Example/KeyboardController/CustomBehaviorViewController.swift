//
//  CustomBehaviorViewController.swift
//  KeyboardController_Example
//
//  Created by Igor Kulik on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import KeyboardController

final class CustomBehaviorViewController: UIViewController {


    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var notOverlappedView: UIView!
    @IBOutlet private weak var viewInFocus: UIView!

    // MARK: - Constraints

    @IBOutlet private weak var contentHeight: NSLayoutConstraint!

    // MARK: - Properties

    private lazy var keyboardController: KeyboardController = { [unowned self] in
        return KeyboardController(view: self.view, constraint: self.contentHeight, adjustmentType: .custom(calculationClosure: self.keyboardDeltaCalculation), scrollView: scrollView)
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

    // MARK: - Private methods

    private lazy var keyboardDeltaCalculation: KeyboardController.DeltaCalculationClosure = { [weak self] keyboardInfo -> CGFloat in
        guard let sSelf = self else { return 0.0 }
        let keyboardHeight = keyboardInfo.keyboardHeightInSafeArea(keyboardFrame: keyboardInfo.endFrame, inside: sSelf.view)
        let contentMaxY = sSelf.notOverlappedView.frame.maxY + sSelf.view.safeAreaInsets.top + 20.0
        let expectedContentHeight = sSelf.scrollView.bounds.height - keyboardHeight - sSelf.viewInFocus.bounds.height
        let delta = contentMaxY - expectedContentHeight
        guard delta > 0 else { // in general case, just reduce view height by keyboard height
            return -keyboardHeight
        }
        return delta - keyboardHeight
    }
}

// MARK: - UITextFieldDelegate
extension CustomBehaviorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
