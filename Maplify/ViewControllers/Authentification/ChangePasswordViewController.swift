//
//  ChangePasswordViewController.swift
//  Maplify
//
//  Created by Sergei on 05/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ChangePasswordViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var passwordInputField: InputTextField!
    @IBOutlet weak var confirmPasswordInputField: InputTextField!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Label.ChangePassword", comment: String())
    }
    
    func setupTextFields() {
        let newPasswordPlaceholder = NSLocalizedString("Text.Placeholder.NewPassword", comment: String())
        self.passwordInputField.setupTextField(newPasswordPlaceholder, defaultIconName: InputTextFieldImages.passwordIconDefault, highlitedIconName: InputTextFieldImages.passwordIconHighlited)
        self.passwordInputField.textField.secureTextEntry = true
        
        let confirmNewPasswordPlaceholder = NSLocalizedString("Text.Placeholder.ConfirmNewPassword", comment: String())
        self.confirmPasswordInputField.setupTextField(confirmNewPasswordPlaceholder, defaultIconName: InputTextFieldImages.passwordIconDefault, highlitedIconName: InputTextFieldImages.passwordIconHighlited)
        self.confirmPasswordInputField.textField.secureTextEntry = true
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        if self.passwordInputField.textField.text?.isValidPassword == false {
            self.passwordInputField.setErrorState(NSLocalizedString("Error.InvalidPassword", comment: String()))
        } else if self.passwordInputField.textField.text != self.confirmPasswordInputField.textField.text {
            self.confirmPasswordInputField.setErrorState(NSLocalizedString("Error.PasswordDoesNotMatch", comment: String()))
        } else {
            self.changePassword()
        }
    }
    
    func changePassword() {
        self.showProgressHUD()
        ApiClient.sharedClient.changePassword(self.passwordInputField.textField.text!, confirmPassword: self.confirmPasswordInputField.textField.text!,
            success: { [weak self] (response) in
                self?.hideProgressHUD()
                SessionManager.saveCurrentUser(response as! User)
                self?.routesSetContentController()
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}