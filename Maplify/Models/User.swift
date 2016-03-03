//
//  User.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class User: Model {
    dynamic var id = Int()
    dynamic var uid = ""
    dynamic var provider = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var photo = ""
    dynamic var homeCity = ""
    dynamic var personalUrl = ""
    dynamic var about = ""
    
    required init() {
        super.init()
    }
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        let userDict = map["user"] as! [String : AnyObject]
        let profileDict = userDict["profile"] as! [String : AnyObject]
        
        self.created_at <- userDict.property("created_at")
        self.updated_at <- userDict.property("updated_at")
        self.email <- userDict.property("email")
        self.provider <- userDict.property("provider")
        self.uid <- userDict.property("uid")
        
        self.id = profileDict["id"] as! Int
        self.firstName <- profileDict.property("first_name")
        self.lastName <- profileDict.property("last_name")
        self.about <- profileDict.property("about")
        self.photo <- profileDict.property("photo_url")
    }
}