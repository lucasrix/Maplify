//
//  FacebookHelper.swift
//  Maplify
//
//  Created by jowkame on 05.04.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Accounts
import FBSDKLoginKit
import FBSDKCoreKit

typealias successFbAuth = (token: String!) -> ()
typealias failureFbAuth = (error: NSError!) -> ()

class FacebookHelper {
    class func setupFacebook(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    class func openUrl(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let isFacebookURL = url.scheme.length > 0 && url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return false
    }
    
    class func activateApp() {
        FBSDKAppEvents.activateApp()
    }

    class func loginByFacebookSDK(success: successFbAuth, failure: failureFbAuth) {
            let facebookReadPermissions = ["public_profile", "email", "user_friends"]
            FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    FBSDKLoginManager().logOut()
                    failure(error: error)
                } else if result.isCancelled {
                    FBSDKLoginManager().logOut()
                    failure(error: nil)
                } else {
                    var allPermsGranted = true
                    let grantedPermissions = (result.grantedPermissions as NSSet).allObjects.map( {"\($0)"} )
                    for permission in facebookReadPermissions {
                        if !grantedPermissions.contains(permission) {
                            allPermsGranted = false
                            break
                        }
                    }
                    if allPermsGranted {
                        let fbToken = result.token.tokenString
                        success(token: fbToken)
                    } else {
                        failure(error: nil)
                    }
                }
            })
        }
    
    class func facebookAuthorize(success: successFbAuth, failure: failureFbAuth) {
        let permissions = ["email"]
        let accountOptions = ["ACFacebookAppIdKey": AppIDs.facebookAppID, ACFacebookPermissionsKey: permissions, ACFacebookAudienceKey: ACFacebookAudienceEveryone]
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        accountStore.requestAccessToAccountsWithType(accountType, options: accountOptions as [NSObject : AnyObject],
                    completion: { (granted, error) -> Void in
                        if (error != nil) {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.loginByFacebookSDK(success, failure: failure)
                            })
                        } else {
                            let accountExist = Bool(accountStore.accountsWithAccountType(accountType).count)
                            if accountExist {
                                let fbAccount = accountStore.accountsWithAccountType(accountType).last as! ACAccount
                                let fbToken = fbAccount.credential.oauthToken
                                success(token: fbToken)
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.loginByFacebookSDK(success, failure: failure)
                                })
                            }
                        }
        })
    }

}