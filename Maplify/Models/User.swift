//
//  User.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class User: Model {
    dynamic var uid = ""
    dynamic var provider = ""
    dynamic var email = ""
    dynamic var profile: Profile! = nil
    
    required init() {
        super.init()
    }
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        let userDict = map["user"] as! [String : AnyObject]
        
        self.created_at <- userDict.property("created_at")
        self.updated_at <- userDict.property("updated_at")
        self.email <- userDict.property("email")
        self.provider <- userDict.property("provider")
        self.uid <- userDict.property("uid")
        self.profile <- userDict.relation("profile")
    }
}