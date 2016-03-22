//
//  NavigationViewController.swift
//  Maplify
//
//  Created by Sergey on 3/3/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit


class NavigationViewController: UINavigationController {

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.topViewController
    }
    
    // MARK: - device orientation support
    override func shouldAutorotate() -> Bool {
        return (self.topViewController?.shouldAutorotate())!
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (self.topViewController?.supportedInterfaceOrientations())!
    }
}
