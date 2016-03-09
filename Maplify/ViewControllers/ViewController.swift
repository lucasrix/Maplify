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
    private let progressHud = ProgressHUD()
    
    // MARK: - view controller life cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTopBar()
        self.populateNavigationBarItems()
    }
    
    // MARK: - progress hud
    func showProgressHUD() {
        self.progressHud.showProgressHUD()
    }
    
    func hideProgressHUD() {
        self.progressHud.hideProgressHUD()
    }
    
    // MARK: - setup
    private func setupTopBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : self.navigationBarTextColor()]
        self.navigationController?.navigationBar.translucent = self.navigationBarIsTranlucent()
        self.navigationController?.navigationBar.setBackgroundImage(self.navigationBarBackgroundImage(), forBarMetrics: .Default)
        UIApplication.sharedApplication().statusBarStyle = self.navigationBarStyle()
    }
    
    private func populateNavigationBarItems() {
        if self.backButtonHidden() {
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationItem.leftBarButtonItem = nil
        } else {
            let backItemimage = UIImage(named: BarButtonImages.backArrow)
            let backItem = UIBarButtonItem(image: backItemimage, style: .Plain, target: self, action: "backTapped")
            backItem.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = backItem
        }
    }
    
    private func navigationBarBackgroundImage() -> UIImage {
        return UIImage(color: self.navigationBarColor())!
    }
    
    // MARK: - methods to override
    func backButtonHidden() -> Bool {
        return false
    }
    
    func backTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
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

