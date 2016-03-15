//
//  SessionManager.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Locksmith

class SessionManager {
    static let sharedManager = SessionManager()
    
    // MARK: - app launch management
    func trackUserAppLaunch() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Config.userAppLaunch)
    }
    
    func appHasAlreadyBeenLaunched() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(Config.userAppLaunch)
    }
    
    func removeAppLaunchTrackingData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Config.userAppLaunch)
    }
    
    // MARK: - network session data management
    func setSessionData(dictionary: [NSObject : AnyObject]!) {
        if dictionary != nil {
            do {
                let sessionDictionary = self.buildDictionary(dictionary)
                try Locksmith.updateData(sessionDictionary, forUserAccount: Config.localUserAccount)
            } catch let error {
                print(error)
            }
        }
    }
    
    func sessionData() -> [NSObject : AnyObject]! {
        let dictionary = Locksmith.loadDataForUserAccount(Config.localUserAccount)
        return (dictionary != nil) ? dictionary : [NSObject : AnyObject]()
    }
    
    func removeSessionData() {
        do {
            try Locksmith.deleteDataForUserAccount(Config.localUserAccount)
        } catch let error {
            print(error)
        }
    }
    
    private func buildDictionary(headers: [NSObject : AnyObject]!) -> [String : String] {
        var sessionDictionary = [String : String]()
       
        let client = headers["client"] as! String
        if client.length > 0 {
            sessionDictionary["client"] = client
        }
        
        let token = headers["access-token"] as! String
        if client.length > 0 {
            sessionDictionary["access-token"] = token
        }
        
        let expiry = headers["expiry"] as! String
        if expiry.length > 0 {
            sessionDictionary["expiry"] = expiry
        }
        
        let uid = headers["uid"] as! String
        if uid.length > 0 {
            sessionDictionary["uid"] = uid
        }
        
        return sessionDictionary
    }
}