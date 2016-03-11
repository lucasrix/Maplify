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
        self.passwordInputField.textField.secureTextEntry = true
    }
    
    func setupNextButton() {
        let nextButton = RoundedButton(frame: Frame.doneButtonFrame)
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
        self.user.email = self.emailInputField.textField.text!
        let password = self.passwordInputField.textField.text
        let photo =  UIImagePNGRepresentation(self.imageView.image!)
        
        self.showProgressHUD()
        
        ApiClient.sharedClient.signUp(self.user, password: password!, passwordConfirmation: password!, photo: photo,
            success: { [weak self] (response) -> () in
                self?.hideProgressHUD()
                self?.routesOpenSignUpUpdateProfileViewController(response as! User)
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                print(errors)
                self?.hideProgressHUD()
                print(statusCode)
            }
        )
    }

}