//
//  UserManager.swift
//  Maplify
//
//  Created by Sergey on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import RealmSwift

class SessionManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]!) -> AnyObject! {
        if response != nil {
            let dictionary = (response["user"] != nil) ? (response["user"] as! [String : AnyObject]) : response
            return User(dictionary)
        } else {
            return nil
        }
    }
    
    class func saveCurrentUser(user: User) {
        let realm = try! Realm()
        try! realm.write {
            let currentUser = realm.create(CurrentUser.self, value: user, update: false)
            realm.add(currentUser)
        }
    }
    
    class func findUser(userId: Int) -> User! {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(User.self, key: userId)
    }
    
    class func currentUser() -> CurrentUser {
        let realm = try! Realm()
        return Array(realm.objects(CurrentUser)).last!
    }
    
    class func removeCurrentUser() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self.currentUser())
        }
    }
}