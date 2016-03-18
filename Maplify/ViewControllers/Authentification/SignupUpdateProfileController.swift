//
//  SignupUpdateProfileController.swift
//  Maplify
//
//  Created by Sergey on 3/10/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

let kMaxAboutTextLength = 255

class SignupUpdateProfileController: ViewController, InputTextViewDelegate {
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
        let nextButton = RoundedButton(frame: Frame.doneButtonFrame)
        nextButton.setTitle(NSLocalizedString("Button.Next", comment: String()), forState: .Normal)
        nextButton.addTarget(self, action: "nextButtonDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: nextButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
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
    func nextButtonDidTap() {
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
                self?.routesSetContentController()
                print(self!.user)
                print(self!.user.profile)
                print(self)
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                print(statusCode)
            }
        )
    }
}