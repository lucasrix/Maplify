//
//  UserListManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import RealmSwift

class UserListManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]!) -> AnyObject! {
        let usersArray: [User]? = response.relations("users")
        return usersArray
    }
    
    class func saveFollowers(users: [User]) {
        for user in users {
            SessionManager.saveUser(user)
        }
    }
    
    class func saveFollowings(users: [User]) {
        for user in users {
            SessionManager.saveUser(user)
        }
    }
}
