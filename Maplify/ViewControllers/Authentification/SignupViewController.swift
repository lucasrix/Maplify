//
//  SignupViewController.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class SignupViewController: ViewController {
    @IBOutlet weak var emailInputField: InputTextField!
    @IBOutlet weak var passwordInputField: InputTextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var photoImage: UIImage! = nil
    
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
        self.setupImageView()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
    }
    
    func setupTextFields() {
        let emailPlaceholder = NSLocalizedString("Text.Placeholder.Email", comment: String())
        let passwordPlaceholder = NSLocalizedString("Text.Placeholder.Password", comment: String())
        
        self.emailInputField.setupTextField(emailPlaceholder, defaultIconName: InputTextFieldImages.emailIconDefault, highlitedIconName: InputTextFieldImages.emailIconHighlited)
        self.passwordInputField.setupTextField(passwordPlaceholder, defaultIconName: InputTextFieldImages.passwordIconDefault, highlitedIconName: InputTextFieldImages.passwordIconHighlited)
    }
    
    func setupNextButton() {
        let nextButton = DoneButton(frame: Frame.doneButtonFrame)
        nextButton.setTitle(NSLocalizedString("Button.Next", comment: String()), forState: .Normal)
        nextButton.addTarget(self, action: "nextButtonDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: nextButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func setupImageView() {
        self.imageView.image = self.photoImage.roundCornersToCircle()
    }
    
    // MARK: - actions
    func nextButtonDidTap() {
    // TODO:
    }

}