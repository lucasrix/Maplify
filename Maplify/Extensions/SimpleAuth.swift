//
//  SimpleAuth.swift
//  Maplify
//
//  Created by Sergey on 3/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import SimpleAuth
import Accounts

let kFacebookProvider = "facebook"
let kFacebookWebProvider = "facebook-web"

typealias successAccountCheck = (granted: Bool, accountsExist: Bool) -> ()
typealias failureAccountCheck = (error: NSError!) -> ()

extension SimpleAuth {
    class func facebookAuthorize(completion: SimpleAuthRequestHandler!) {
        let options = ["app_id": AppIDs.facebookAppID, "redirect_uri": ConfigHepler.baseHostUrl()]
        let permissions = ["email"]
        let accountOptions = ["ACFacebookAppIdKey": AppIDs.facebookAppID, ACFacebookPermissionsKey: permissions, ACFacebookAudienceKey: ACFacebookAudienceEveryone]
        self.checkSocialAccount(ACAccountTypeIdentifierFacebook, options: accountOptions as! [String : AnyObject],
            success: {(granted, accountsExist) -> () in
                self.login(kFacebookProvider, options: options, completion: completion)
            },
            failure:  {(error) -> () in
                if (UInt32(error.code) == ACErrorAccountNotFound.rawValue) {
                    self.login(kFacebookWebProvider, options: options, completion: completion)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil, error)
                    }
                }
            }
        )
    }
    
    class func login(provider: String, options: [String: AnyObject], completion: SimpleAuthRequestHandler!) {
        SimpleAuth.authorize(provider, options: options, completion: completion)
    }
    
    class func checkSocialAccount(typeID: String, options: [String: AnyObject], success: successAccountCheck, failure: failureAccountCheck) {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(typeID)
        accountStore.requestAccessToAccountsWithType(accountType, options: options,
            completion:  { (granted, error) -> Void in
                if (error != nil) {
                    failure(error: error)
                } else {
                    let accountExist = Bool(accountStore.accountsWithAccountType(accountType).count)
                    success(granted: granted, accountsExist: accountExist)
                }
        })
    }
}

