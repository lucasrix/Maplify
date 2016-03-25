//
//  UserManager.swift
//  Maplify
//
//  Created by Sergey on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import RealmSwift

class UserManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let dictionary = (response["user"] != nil) ? (response["user"] as! [String : AnyObject]) : response
        return User(dictionary)
    }
    
    class func saveCurrentUser(user: User) {
        let realm = try! Realm()
        try! realm.write {
            let currentUser = realm.create(CurrentUser.self, value: user, update: false)
            realm.add(currentUser)
        }
    }
    
    class func currentUser() -> CurrentUser {
        let realm = try! Realm()
        return Array(realm.objects(CurrentUser)).last!
    }
    
    class func removeCurrentUser() {
        let realm = try! Realm()
        realm.delete(self.currentUser())
    }
}