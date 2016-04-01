//
//  SignupUpdateProfileController.swift
//  Maplify
//
//  Created by Sergey on 3/10/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

let kMaxAboutTextLength = 500

class SignupUpdateProfileController: ViewController, InputTextViewDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var locationInputField: InputTextField!
    @IBOutlet weak var urlInputField: InputTextField!
    @IBOutlet weak var aboutInputField: InputTextView!
    @IBOutlet weak var aboutFieldHeightConstraint: NSLayoutConstraint!
    
    var user: User! = nil
    var placesClient: GMSPlacesClient! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.aboutInputField.registerForKeyboardNotifications(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.aboutInputField.unregisterForKeyboardNotifications(self)
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.setupNextButton()
        self.retrieveCurrentPlace()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
    }
    
    func setupTextFields() {
        self.setupLocationInputField()
        self.setupURLInputField()
        self.setupAboutInputField()
    }
    
    func setupLocationInputField() {
        let locationPlaceholder = NSLocalizedString("Text.Placeholder.Location", comment: String())
        let locationDescription = NSLocalizedString("InputField.Description.City", comment: String())
        
        self.locationInputField.setupTextField(locationPlaceholder, defaultIconName: InputTextFieldImages.locationIconDefault, highlitedIconName: InputTextFieldImages.locationIconActive)
        self.locationInputField.descriptionLabel.text = locationDescription
    }
    
    func setupURLInputField() {
        let urlLPlaceholder = NSLocalizedString("Text.Placeholder.PersonalURL", comment: String())
        let optionalDescription = NSLocalizedString("InputField.Description.Optional", comment: String())

        self.urlInputField.setupTextField(urlLPlaceholder, defaultIconName: InputTextFieldImages.iconUrlDefault, highlitedIconName: InputTextFieldImages.iconUrlActive)
        self.urlInputField.descriptionLabel.text = optionalDescription
    }
    
    func setupAboutInputField() {
        let locationAboutPlaceholder = NSLocalizedString("Text.Placeholder.AboutYou", comment: String())
        let optionalDescription = NSLocalizedString("InputField.Description.Optional", comment: String())
        
        self.aboutInputField.setupTextField(locationAboutPlaceholder, defaultIconName: InputTextFieldImages.iconInfoDefault, highlitedIconName: InputTextFieldImages.iconInfoActive)
        self.aboutInputField.rightDetailLabel.text = optionalDescription
        self.aboutInputField.maxCharLength = kMaxAboutTextLength
        self.aboutInputField.delegate = self
    }

    func setupNextButton() {
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
    }
    
    func retrieveCurrentPlace() {
        self.placesClient = GMSPlacesClient()
        self.placesClient.currentPlaceWithCallback { [weak self] (placesList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if (error != nil) {
                print(error)
            } else {
                if let placeLikelihoodList = placesList {
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        self?.locationInputField.textField.text = place.name
                    }
                }
            }
        }
    }
    
    // MARK: - InputTextViewDelegate
    func editingChanged(inputTextView: InputTextView) {
        let height = inputTextView.textView.frame.height
        self.aboutFieldHeightConstraint.constant = height
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        self.locationInputField.textField.endEditing(true)
        self.urlInputField.textField.endEditing(true)
        self.aboutInputField.textView.endEditing(true)
        
        self.user.profile.city = self.locationInputField.textField.text!
        self.user.profile.url = self.urlInputField.textField.text!
        self.user.profile.about = self.aboutInputField.textView.text
        
        self.showProgressHUD()
        ApiClient.sharedClient.updateProfile(self.user.profile,
            success: { [weak self] (response) -> () in
                self?.user.profile = response as! Profile  
                self?.hideProgressHUD()
                UserManager.saveCurrentUser((self?.user)!)
                self?.routesOpenOnboardController()
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    //MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}