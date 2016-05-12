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
        let realm = try! Realm()
        
        for user in users {
            try! realm.write {
                user.is_follower = true
                realm.add(user, update: true)
            }
        }
    }
    
    class func saveFollowings(users: [User]) {
        let realm = try! Realm()
        
        for user in users {
            try! realm.write {
                user.is_following = true
                realm.add(user, update: true)
            }
        }
    }
}
