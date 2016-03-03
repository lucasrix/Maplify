//
//  SignupViewController.swift
//  Maplify
//
//  Created by Sergey on 3/3/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var firstNameField: InputTextField!
    @IBOutlet weak var lastNameField: InputTextField!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupTextFields()
        self.setupImageView()
    }
    
    func setupTextFields() {
        self.firstNameField.setupTextField(NSLocalizedString("Text.Placeholder.FirstName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.firstNameField.textField.textAlignment = NSTextAlignment.Center
        self.lastNameField.setupTextField(NSLocalizedString("Text.Placeholder.LastName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.lastNameField.textField.textAlignment = NSTextAlignment.Center
    }
    
    func setupImageView() {
        
    }
}