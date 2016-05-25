//
//  ReportSuccessViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class ReportSuccessViewController: ViewController {
    var completionClosure: (() -> ())! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupTitle()
    }
    
    func setupTitle() {
        self.title = NSLocalizedString("Controller.Reports", comment: String())
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
}
