//
//  ResetPasswordViewController.swift
//  Maplify
//
//  Created by Sergei on 04/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ResetPasswordViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var emailInputField: InputTextField!
    @IBOutlet weak var detailsLabel: UILabel!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.addRightBarItem(NSLocalizedString("Button.Reset", comment: String()))
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.ResetPassword", comment: String())
        self.detailsLabel.text = NSLocalizedString("Label.ResetPasswordDetails", comment: String())
    }
    
    func setupTextFields() {
        let emailPlaceholder = NSLocalizedString("Text.Placeholder.Email", comment: String())
        self.emailInputField.setupTextField(emailPlaceholder, defaultIconName: InputTextFieldImages.emailIconDefault, highlitedIconName: InputTextFieldImages.emailIconHighlited)
        self.emailInputField.textField.keyboardType = .EmailAddress
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        if self.emailInputField.textField.text?.isEmail == true {
            self.showProgressHUD()
            ApiClient.sharedClient.resetPassword(self.emailInputField.textField.text!, redirectUrl: Network.routingPrefix,
                success: { [weak self] (response) in
                    let cancel = NSLocalizedString("Button.Ok", comment: String())
                    let message =  NSLocalizedString("Label.LinkWasSent", comment: String())
                    self?.hideProgressHUD()
                    self?.showAlert(nil, message: message, cancel: cancel, buttons: nil, handle: { (buttonIndex) in
                        self?.navigationController?.popViewControllerAnimated(true)
                    })
                },
                failure: { [weak self] (statusCode, errors, localDescription, messages) in
                    self?.hideProgressHUD()
                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                })
        } else {
            self.emailInputField.setErrorState(NSLocalizedString("Error.InvalidEmail", comment: String()))
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}