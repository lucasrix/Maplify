//
//  ViewController.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiClient.sharedClient.signUp("test12@test.test", password: "12345678", passwordConfirmation: "12345678",
            success: { (response) -> () in
                print(response)
            },
            failure: { (statusCode, errors, localDescription, messages) -> () in
                print(statusCode)
            }
        )
    }
}

