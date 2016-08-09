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
import GoogleMaps
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.setupFabric()
        self.setupGoogleServices()
        self.setupMixpanel()
        FacebookHelper.setupFacebook(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.absoluteString.containsString(Network.routingPrefix + Network.sharePrefix) {
            let params = url.queryItems
            let sharedType = params[SharingKeys.typeTitle]
            let sharedId = Int(params[SharingKeys.typeId]!)
            
            if self.window?.rootViewController is NavigationViewController {
                let navigationController = self.window?.rootViewController as! NavigationViewController
                let viewController = navigationController.viewControllers.first
                viewController!.routesOpenSharedContentController(sharedType!, sharedId: sharedId!)
            } else {
                self.window?.rootViewController?.routesOpenSharedContentController(sharedType!, sharedId: sharedId!)
            }
        } else if url.absoluteString.containsString(Network.routingPrefix) {
            SessionHelper.sharedHelper.setSessionData(url)
            if self.window?.rootViewController is NavigationViewController {
                let navigationController = self.window?.rootViewController as! NavigationViewController
                let viewController = navigationController.viewControllers.first
                viewController!.routesOpenChangePasswordViewController()
            } else {
                self.window?.rootViewController?.routesOpenChangePasswordViewController()
            }
            
        } else {
            return FacebookHelper.openUrl(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FacebookHelper.activateApp()
    }
    
    func setupFabric() {
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = ConfigHepler.isProduction()
    }
    
    func setupGoogleServices() {
        GMSServices.provideAPIKey(ConfigHepler.googleProjectKey())
    }
    
    func setupMixpanel() {
        let token = ConfigHepler.mixpanelToken()
        Mixpanel.sharedInstanceWithToken(token)
        Mixpanel.sharedInstance().identify(Mixpanel.sharedInstance().distinctId)
        print("Dist ID - \(Mixpanel.sharedInstance().distinctId)")
    }
}

