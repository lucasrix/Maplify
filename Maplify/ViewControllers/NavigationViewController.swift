//
//  NavigationViewController.swift
//  Maplify
//
//  Created by Sergey on 3/3/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kNotificationNameSignOut = "NotificationNameSignOut"

enum NavigationType: Int {
    case Auth
    case Main
}

class NavigationViewController: UINavigationController {
    var navigationType: NavigationType = .Auth

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kNotificationNameSignOut, object: nil)
    }
    
    // MARK: - setup
    func setup() {
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.subscribeNotifications()
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
    
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationViewController.signOut), name: kNotificationNameSignOut, object: nil)
    }
    
    func signOut() {
        if self.navigationType == .Main {
            SessionHelper.sharedHelper.removeSessionData()
            SessionHelper.sharedHelper.removeSessionAuthCookies()
            SessionHelper.sharedHelper.removeDatabaseData()
            SessionHelper.sharedHelper.removeImageCacheData()
            RootViewController.navigationController().routesSetLandingController()
        }
    }
}
