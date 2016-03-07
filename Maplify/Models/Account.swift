//
//  Account.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class Account: User {
    
    required init() {
        super.init()
    }
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.created_at <- map.property("created_at")
        self.updated_at <- map.property("updated_at")
        self.email <- map.property("email")
        self.provider <- map.property("provider")
        self.uid <- map.property("uid")
        
        self.firstName <- map.property("first_name")
        self.lastName <- map.property("last_name")
        self.about <- map.property("about")
        self.photo <- map.property("photo_url")
    }
}
