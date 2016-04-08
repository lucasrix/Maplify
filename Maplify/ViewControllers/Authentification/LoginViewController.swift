//
//  LoginViewController.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class LoginViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var emailInputField: InputTextField!
    @IBOutlet weak var passwordInputField: InputTextField!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.setupDoneButton()        
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Login.Title", comment: String())
    }
    
    func setupTextFields() {
        let emailPlaceholder = NSLocalizedString("Text.Placeholder.Email", comment: String())
        let passwordPlaceholder = NSLocalizedString("Text.Placeholder.Password", comment: String())
        
        self.emailInputField.setupTextField(emailPlaceholder, defaultIconName: InputTextFieldImages.emailIconDefault, highlitedIconName: InputTextFieldImages.emailIconHighlited)
        self.emailInputField.textField.keyboardType = .EmailAddress
        self.passwordInputField.setupTextField(passwordPlaceholder, defaultIconName: InputTextFieldImages.passwordIconDefault, highlitedIconName: InputTextFieldImages.passwordIconHighlited)
        self.passwordInputField.textField.secureTextEntry = true
    }
    
    func setupDoneButton() {
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    // MARK: - Actions
    override func rightBarButtonItemDidTap() {
        self.emailInputField.textField.endEditing(true)
        self.passwordInputField.textField.endEditing(true)
        
        self.showProgressHUD()
        
        ApiClient.sharedClient.signIn(self.emailInputField.textField.text!, password: self.passwordInputField.textField.text!,
            success: { [weak self] (response) -> () in
                self?.hideProgressHUD()
                self?.routesSetContentController()
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    // MARK: - ErrorHandlingProtocol 
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
        self.emailInputField.setErrorState(NSLocalizedString("Error.InvalidEmail", comment: String()))
        self.passwordInputField.setErrorState(NSLocalizedString("Error.InvalidPassword", comment: String()))
    }
}