//
//  LoginViewController.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class LoginViewController: ViewController {
    
    @IBOutlet weak var emailTextField: InputTextField!
    @IBOutlet weak var passwordTextField: InputTextField!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
       self.setupLabels()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Login.Title", comment: String())
    }
    
    func setupTextFields() {
        
    }
    
}