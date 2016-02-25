//
//  AppDelegate.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.setupFabric()
        return true
    }
    
    func setupFabric() {
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = ConfigHepler.isProduction()
    }
}

