//
//  ViewController.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import AFImageHelper

class ViewController: UIViewController {

    // MARK: - view controller life cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTopBar()
    }
    
    // MARK: - setup
    private func setupTopBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : self.navigationBarTextColor()]
        self.navigationController?.navigationBar.translucent = self.navigationBarIsTranlucent()
        self.navigationController?.navigationBar.setBackgroundImage(self.navigationBarBackgroundImage(), forBarMetrics: .Default)
        UIApplication.sharedApplication().statusBarStyle = self.navigationBarStyle()
    }
    
    private func navigationBarBackgroundImage() -> UIImage {
        return UIImage(color: self.navigationBarColor())!
    }
    
    // MARK: - methods to override
    func navigationBarIsTranlucent() -> Bool {
        return true
    }
    
    func navigationBarColor() -> UIColor {
        return UIColor.clearColor()
    }
    
    func navigationBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func navigationBarTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
}

