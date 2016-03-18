//
//  Account.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class Profile: Model {
    dynamic var id = Int()
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var photo = ""
    dynamic var city = ""
    dynamic var url = ""
    dynamic var about = ""

    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id = map["id"] as! Int
        self.firstName <- map.property("first_name")
        self.lastName <- map.property("last_name")
        self.about <- map.property("about")
        self.city <- map.property("city")
        self.url <- map.property("url")
        self.photo <- map.property("photo_url")
    }
}
