//
//  SignupUpdateProfileController.swift
//  Maplify
//
//  Created by Sergey on 3/10/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

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
        let locationPlaceholder = NSLocalizedString("Text.Placeholder.Location", comment: String())
        let urlLPlaceholder = NSLocalizedString("Text.Placeholder.PersonalURL", comment: String())
        let locationAboutPlaceholder = NSLocalizedString("Text.Placeholder.AboutYou", comment: String())
        
        self.locationInputField.setupTextField(locationPlaceholder, defaultIconName: InputTextFieldImages.locationIconDefault, highlitedIconName: InputTextFieldImages.locationIconActive)
        self.urlInputField.setupTextField(urlLPlaceholder, defaultIconName: InputTextFieldImages.iconUrlDefault, highlitedIconName: InputTextFieldImages.iconUrlActive)
        self.aboutInputField.setupTextField(locationAboutPlaceholder, defaultIconName: InputTextFieldImages.iconInfoDefault, highlitedIconName: InputTextFieldImages.iconInfoActive)
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
        
        let location = self.locationInputField.textField.text
        let url = self.urlInputField.textField.text
        let about = self.aboutInputField.textView.text
        
        self.showProgressHUD()
        ApiClient.sharedClient.updateProfile(location!, personalUrl: url!, about: about,
            success: { [weak self] (response) -> () in
                self?.hideProgressHUD()
                print(response)
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                print(statusCode)
            }
        )
    }
}