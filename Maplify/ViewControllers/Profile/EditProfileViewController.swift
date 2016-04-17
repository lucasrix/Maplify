//
//  EditProfileViewController.swift
//  Maplify
//
//  Created by Sergei on 15/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TPKeyboardAvoiding

let kAboutFieldBorderWidth: CGFloat = 1

class EditProfileViewController: ViewController, UITextFieldDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var avoidingKeyboardScrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var homeCityLabel: UILabel!
    @IBOutlet weak var homeCityTextField: UITextField!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var aboutYouLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    var profileId: Int = 0
    var user: User! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.loadItemFromDB()
        self.setupLabels()
        self.setupButtons()
        self.setupTextFields()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.EditProfile", comment: String())
        self.firstNameLabel.text = NSLocalizedString("Text.Placeholder.FirstName", comment: String())
        self.lastNameLabel.text = NSLocalizedString("Text.Placeholder.LastName", comment: String())
        self.emailLabel.text =  NSLocalizedString("Text.Placeholder.Email", comment: String())
        self.homeCityLabel.text = NSLocalizedString("Text.Placeholder.Location", comment: String())
        self.urlLabel.text = NSLocalizedString("Text.Placeholder.PersonalURL", comment: String())
        self.aboutYouLabel.text = NSLocalizedString("Text.Placeholder.AboutYou", comment: String())
        self.firstNameErrorLabel.text = NSLocalizedString("Error.InvalidFirstName", comment: String())
        self.emailLabel.text = NSLocalizedString("Error.EnterValidEmail", comment: String())
    }
    
    func setupButtons() {
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
    }
    
    func setupTextFields() {
        self.firstNameTextField.delegate = self
        self.emailTextField.delegate = self
        
        self.emailTextField.layer.borderWidth = kAboutFieldBorderWidth
        self.emailTextField.layer.cornerRadius = CornerRadius.defaultRadius
        self.emailTextField.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.firstNameTextField.layer.borderWidth = kAboutFieldBorderWidth
        self.firstNameTextField.layer.cornerRadius = CornerRadius.defaultRadius
        self.firstNameTextField.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.lastNameTextField.layer.borderWidth = kAboutFieldBorderWidth
        self.lastNameTextField.layer.cornerRadius = CornerRadius.defaultRadius
        self.lastNameTextField.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.homeCityTextField.layer.borderWidth = kAboutFieldBorderWidth
        self.homeCityTextField.layer.cornerRadius = CornerRadius.defaultRadius
        self.homeCityTextField.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.urlTextField.layer.borderWidth = kAboutFieldBorderWidth
        self.urlTextField.layer.cornerRadius = CornerRadius.defaultRadius
        self.urlTextField.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.aboutTextView.layer.cornerRadius = CornerRadius.defaultRadius
        self.aboutTextView.clipsToBounds = true
        self.aboutTextView.layer.borderWidth = kAboutFieldBorderWidth
        self.aboutTextView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        let view = UIView(frame: CGRectMake(0, 0, kLocationInputFieldRightMargin, self.homeCityTextField.frame.size.height))
        self.homeCityTextField.rightViewMode = .Always
        self.homeCityTextField.rightView = view
        
        self.firstNameTextField.text = self.user.profile.firstName
        self.lastNameTextField.text = self.user.profile.lastName
        self.homeCityTextField.text = self.user.profile.city
        self.urlTextField.text = self.user.profile.url
        self.aboutTextView.text = self.user.profile.about
        self.emailTextField.text = self.user.email
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        let firstNameValid = ((self.firstNameTextField.text?.length)! > 0) && (self.firstNameTextField.text?.isNonWhiteSpace)!
        let emailValid = self.emailTextField.text?.isEmail
        
        self.firstNameErrorLabel.hidden = firstNameValid
        self.emailErrorLabel.hidden = emailValid!
        self.firstNameTextField.layer.borderColor = firstNameValid ? UIColor.inactiveGrey().CGColor : UIColor.errorRed().CGColor
        self.emailTextField.layer.borderColor = emailValid! ? UIColor.inactiveGrey().CGColor : UIColor.errorRed().CGColor
        
        let profile = Profile()
        profile.lastName = self.lastNameTextField.text!
        profile.url = self.urlTextField.text!
        profile.city = self.homeCityTextField.text!
        profile.about = self.aboutTextView.text
        self.user.profile = profile
        
        if firstNameValid && emailValid! {
            self.user.email = self.emailTextField.text!
            profile.firstName = self.firstNameTextField.text!
            self.navigationController?.popViewControllerAnimated(true)

            self.showProgressHUD()
            ApiClient.sharedClient.updateProfile(self.user,
                   success: { [weak self] (response) in
                    let profile = response as! Profile
                    self?.user.profile = profile
                    ProfileManager.saveProfile(profile)
                        self?.hideProgressHUD()
                        self?.navigationController?.popViewControllerAnimated(true)
                   },
                   failure: { [weak self] (statusCode, errors, localDescription, messages) in
                        self?.hideProgressHUD()
                        self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                   }
            )
        }
    }
    
    func loadItemFromDB() {
        self.user = SessionManager.currentUser()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor.inactiveGrey().CGColor
        if textField == self.emailTextField {
            self.emailErrorLabel.hidden = true
        } else if textField == self.firstNameTextField {
            self.firstNameErrorLabel.hidden = true
        }
    }

    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}