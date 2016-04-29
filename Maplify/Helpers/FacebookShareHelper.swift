//
//  FacebookShareHelper.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/29/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit
import UIKit

class FacebookShareHelper: NSObject {
    
    var callback: ((success: Bool) ->())! = nil
    
    func shareContent(controller: UIViewController, title: String, description: String, imageUrl: NSURL!, callback: ((success: Bool) -> ())!) {
        self.callback = callback
        self.checkPermissions { (success) in
            if success == true {
                self.post(controller, title: title, description: description, imageUrl: imageUrl)
            } else {
                self.callback(success: false)
            }
        }
    }
    
    func checkPermissions(callback: ((success: Bool) -> ())!) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            callback(success: true)
        } else {
            FBSDKLoginManager().logInWithPublishPermissions(["publish_actions"], handler: { (result, error) in
                if (error == nil) && (result.isCancelled == false) {
                    callback(success: true)
                } else {
                    callback(success: false)
                }
            })
        }
    }
    
    private func post(controller: UIViewController, title: String, description: String, imageUrl: NSURL!) {
        
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = title
        content.contentDescription = description
        content.contentURL = NSURL(string: Links.landingLink)
        
        content.imageURL = imageUrl
        FBSDKShareDialog.showFromViewController(controller, withContent: content, delegate: nil)
        self.callback(success: true)
    }
}
