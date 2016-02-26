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
    
    func setSessionData(dictionary: [NSObject : AnyObject]!) {
        do {
            try Locksmith.saveData(["hi": "test"], forUserAccount: Config.localUserAccount)
        } catch let error {
            print(error)
        }
    }
}