//
//  OnboardViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class OnboardViewController: ViewController {
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.openPageController()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupNavigationBarItems()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
    }
    
    func setupNavigationBarItems() {
        let nextButton = RoundedButton(frame: Frame.doneButtonFrame)
        nextButton.setTitle(NSLocalizedString("Button.Next", comment: String()), forState: .Normal)
        nextButton.addTarget(self, action: "nextButtonDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: nextButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func openPageController() {
        let pageViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.pageViewController)
        self.configureChildViewController(pageViewController, onView: self.view)
    }
}
