//
//  SignupViewController.swift
//  Maplify
//
//  Created by Sergey on 3/3/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kLabelCornerRadius: CGFloat = 5

class SignupViewController: ViewController {
    @IBOutlet weak var firstNameField: InputTextField!
    @IBOutlet weak var lastNameField: InputTextField!
    @IBOutlet weak var setPhotoLabelView: UIView!
    @IBOutlet weak var setPhotoLabel: UILabel!
    @IBOutlet weak var setPhotoImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.setupPhotoLabelView()
        self.setupImageView()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
        self.descriptionLabel.text = NSLocalizedString("Controller.Signup.description", comment: String())
        self.setPhotoLabel.text = NSLocalizedString("Controller.Signup.setPhoto", comment: String())
    }
    
    func setupTextFields() {
        self.firstNameField.setupTextField(NSLocalizedString("Text.Placeholder.FirstName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.firstNameField.textField.textAlignment = NSTextAlignment.Center
        self.lastNameField.setupTextField(NSLocalizedString("Text.Placeholder.LastName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.lastNameField.textField.textAlignment = NSTextAlignment.Center
    }
    
    func setupPhotoLabelView() {
        self.setPhotoLabelView.layer.cornerRadius = kLabelCornerRadius
        self.setPhotoLabelView.clipsToBounds = true
    }
    
    func setupImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "imageViewDidTap")
        self.setPhotoImage.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - actions
    func imageViewDidTap() {
        print("user did tap")
    }
}