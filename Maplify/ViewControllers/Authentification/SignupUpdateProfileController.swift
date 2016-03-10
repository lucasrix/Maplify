//
//  SignupUpdateProfileController.swift
//  Maplify
//
//  Created by Sergey on 3/10/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GooglePlaces

class SignupUpdateProfileController: ViewController {
    @IBOutlet weak var locationInputField: InputTextField!
    @IBOutlet weak var urlInputField: InputTextField!
    @IBOutlet weak var aboutInputField: InputTextField!
    
    var user: User! = nil

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
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
        let locationPlaceholder = NSLocalizedString("Text.Placeholder.Location", comment: String())
        let urlLPlaceholder = NSLocalizedString("Text.Placeholder.PersonalURL", comment: String())
        let locationAboutPlaceholder = NSLocalizedString("Text.Placeholder.AboutYou", comment: String())
        
        self.locationInputField.setupTextField(locationPlaceholder, defaultIconName: InputTextFieldImages.locationIconDefault, highlitedIconName: InputTextFieldImages.locationIconActive)
        self.urlInputField.setupTextField(urlLPlaceholder, defaultIconName: InputTextFieldImages.iconUrlDefault, highlitedIconName: InputTextFieldImages.iconUrlActive)
        self.aboutInputField.setupTextField(locationAboutPlaceholder, defaultIconName: InputTextFieldImages.iconInfoDefault, highlitedIconName: InputTextFieldImages.iconInfoActive)
    }
    
    func setupNextButton() {
        let nextButton = RoundedButton(frame: Frame.doneButtonFrame)
        nextButton.setTitle(NSLocalizedString("Button.Next", comment: String()), forState: .Normal)
        nextButton.addTarget(self, action: "nextButtonDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: nextButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    // MARK: - actions
    func nextButtonDidTap() {
    // TODO:
    }
}