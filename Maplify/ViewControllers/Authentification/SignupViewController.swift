//
//  SignupViewController.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TPKeyboardAvoiding

class SignupViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var emailInputField: InputTextField!
    @IBOutlet weak var passwordInputField: InputTextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var keyboardAvoidingScrollView: TPKeyboardAvoidingScrollView!

    var placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
    var photoImage: UIImage! = nil
    var user: User! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupKeyboardAvoidingScrollView()
        self.setupLabels()
        self.setupTextFields()
        self.setupNextButton()
        self.setupImageView()
    }
    
    func setupKeyboardAvoidingScrollView() {
        if UIScreen.mainScreen().smallerThanIPhoneSixSize() == false {
            self.keyboardAvoidingScrollView.disableKeyboardAvoiding()
        }
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
    }
    
    func setupTextFields() {
        let emailPlaceholder = NSLocalizedString("Text.Placeholder.Email", comment: String())
        let passwordPlaceholder = NSLocalizedString("Text.Placeholder.Password", comment: String())
        
        self.emailInputField.setupTextField(emailPlaceholder, defaultIconName: InputTextFieldImages.emailIconDefault, highlitedIconName: InputTextFieldImages.emailIconHighlited)
        self.emailInputField.textField.keyboardType = .EmailAddress
        self.passwordInputField.setupTextField(passwordPlaceholder, defaultIconName: InputTextFieldImages.passwordIconDefault, highlitedIconName: InputTextFieldImages.passwordIconHighlited)
        self.passwordInputField.textField.secureTextEntry = true
        
        self.emailInputField.descriptionLabel.text = NSLocalizedString("InputField.Description.Email", comment: String())
        self.passwordInputField.descriptionLabel.text = NSLocalizedString("InputField.Description.Password", comment: String())
    }
    
    func setupNextButton() {
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
    }
    
    func setupImageView() {
        self.imageView.image = (self.photoImage != nil) ? self.photoImage.roundCornersToCircle() : self.placeholderImage
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        self.emailInputField.textField.endEditing(true)
        self.passwordInputField.textField.endEditing(true)
        
        if self.emailInputField.textField.text?.isEmail == false {
            self.showMessageAlert(nil, message: NSLocalizedString("Error.InvalidEmail", comment: String()), cancel: NSLocalizedString("Button.Ok", comment: String()))
        } else if self.passwordInputField.textField.text?.isValidPassword == false {
            self.showMessageAlert(nil, message: NSLocalizedString("Error.InvalidPassword", comment: String()), cancel: NSLocalizedString("Button.Ok", comment: String()))
        } else {
            self.signup()
        }
        
        self.markInputFieldsWithErrorIfNeeded()
    }
    
    func markInputFieldsWithErrorIfNeeded() {
        if self.emailInputField.textField.text?.isEmail == false {
            self.emailInputField.setErrorState(NSLocalizedString("Error.InvalidEmail", comment: String()))
        }
        
        if self.passwordInputField.textField.text?.isValidPassword == false {
            self.passwordInputField.setErrorState(NSLocalizedString("Error.InvalidPassword", comment: String()))
        }
    }
    
    func signup() {
        self.user.email = self.emailInputField.textField.text!
        let password = self.passwordInputField.textField.text
        let photo = (self.photoImage != nil) ? UIImagePNGRepresentation(self.photoImage) : nil
        
        self.showProgressHUD()
        
        let profile = user.profile
        
        ApiClient.sharedClient.signUp(self.user, password: password!, passwordConfirmation: password!, photo: photo,
            success: { [weak self] (response) -> () in
                let user = response as! User
                user.profile = profile
                SessionManager.saveCurrentUser(user)
                self?.updateProfileRemote(user)
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    func updateProfileRemote(user: User!) {
        ApiClient.sharedClient.updateProfile(user.profile, location: nil, success: { [weak self] (response) in
            self?.updateProfile(user.profile, completion: { [weak self] (profile) in
                if profile != nil {
                    user.profile = profile
                    SessionManager.saveCurrentUser(user)
                }
                self?.hideProgressHUD()
                self?.routesOpenSignupGetCityViewController(user)
            })
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    private func updateProfile(profile: Profile!, completion: ((profile: Profile!) -> ())!) {
        ApiClient.sharedClient.updateProfile(profile, location: nil, success: { (response) in
            completion?(profile: response as! Profile)
            }) { (statusCode, errors, localDescription, messages) in
                completion?(profile: nil)
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}