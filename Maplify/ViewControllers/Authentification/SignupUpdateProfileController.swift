//
//  SignupUpdateProfileController.swift
//  Maplify
//
//  Created by Sergey on 3/10/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps
import TPKeyboardAvoiding

let kMaxAboutTextLength = 500
let kTopControlsHeight: CGFloat = 200

class SignupUpdateProfileController: ViewController, InputTextFieldDelegate, InputTextViewDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var locationInputField: InputTextField!
    @IBOutlet weak var urlInputField: InputTextField!
    @IBOutlet weak var aboutInputField: InputTextView!
    @IBOutlet weak var aboutFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardAvoidingScrollView: TPKeyboardAvoidingScrollView!
    
    var user: User! = nil
    var placesClient: GMSPlacesClient! = nil
    var suspender = Suspender()
    
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
        self.locationInputField.delegate = self
        self.locationInputField.textField.completionColor = UIColor.lightGrayColor()
    }
    
    func setupURLInputField() {
        let urlLPlaceholder = NSLocalizedString("Text.Placeholder.PersonalURL", comment: String())
        let optionalDescription = NSLocalizedString("InputField.Description.Optional", comment: String())

        self.urlInputField.setupTextField(urlLPlaceholder, defaultIconName: InputTextFieldImages.iconUrlDefault, highlitedIconName: InputTextFieldImages.iconUrlActive)
        self.urlInputField.descriptionLabel.text = optionalDescription
        self.urlInputField.textField.keyboardType = .URL
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
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - InputTextViewDelegate
    func textEditingChanged(inputTextView: InputTextView) {
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
        ApiClient.sharedClient.updateProfile(self.user.profile, photo: nil,
            success: { [weak self] (response) -> () in
                self?.user.profile = response as! Profile  
                self?.hideProgressHUD()
                SessionManager.saveCurrentUser((self?.user)!)
                let defaultLocation = CLLocation(latitude: DefaultLocation.washingtonDC.0 , longitude: DefaultLocation.washingtonDC.1)
                SessionHelper.sharedHelper.updateUserLastLocationIfNeeded(defaultLocation)
                self?.routesOpenOnboardController()
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    // MARK: - InputTextFieldDelegate
    func shouldChangeCharacters(inputTextField: InputTextField, replacementString string: String) {
        let filter = GMSAutocompleteFilter()
        filter.type = .NoFilter
        GMSPlacesClient.sharedClient().autocompleteQuery(string, bounds: nil, filter: filter,
                                                callback: { [weak self] (predictions, error) in
                                                    if predictions?.count > 0 {
                                                        let predictionTitles = (predictions! as [GMSAutocompletePrediction]).map({$0.attributedFullText})
                                                        let location = (predictionTitles.first?.string)! as String
                                                        self?.locationInputField.textField.suggestions = [location]
                                                    }
            }
        )
    }
    
    func contentSizeWillChange(contentSize: CGSize) {
        let contentWidth = self.view.frame.size.width
        let updatedContentHeight = contentSize.height + kTopControlsHeight
        self.keyboardAvoidingScrollView.contentSize = CGSizeMake(contentWidth, updatedContentHeight)
        self.keyboardAvoidingScrollView.scrollRectToVisible(CGRectMake(0, 0, contentWidth, updatedContentHeight), animated: true)
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}