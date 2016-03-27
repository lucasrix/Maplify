//
//  MenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class MenuViewController: ViewController {
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        
    }
    
    // MARK: - actions
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
