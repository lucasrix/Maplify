//
//  RootViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class RootViewController: ViewController {
   
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SessionHelper.sharedManager.isSesstionTokenExists() {
            self.routesSetContentController()
        } else {
            self.routesSetLandingController()
        }
    }
    
    class func navigationController() -> NavigationViewController {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.window!.rootViewController as! NavigationViewController
    }
}