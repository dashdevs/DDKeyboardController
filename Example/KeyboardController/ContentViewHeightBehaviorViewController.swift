//
//  ContentViewHeightBehaviorViewController.swift
//  KeyboardController
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import UIKit
import KeyboardController

final class ContentViewHeightBehaviorViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var infoLabel: UILabel!

    // MARK: - Constraints
    
    @IBOutlet private weak var contentHeight: NSLayoutConstraint!

    // MARK: - Properties

    private lazy var keyboardController: KeyboardController = { [unowned self] in
        return KeyboardController(view: self.view, constraint: self.contentHeight, adjustmentType: .contentViewHeight)
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardController.addKeyboardNotificationObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController.removeKeyboardNotificationObservers()
    }
}

// MARK: - UITextFieldDelegate
extension ContentViewHeightBehaviorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
