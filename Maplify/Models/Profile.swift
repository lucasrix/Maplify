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
        
        let dictionary = (map["profile"] != nil) ? (map["profile"] as! [String : AnyObject]) : map
        
        self.id = dictionary["id"] as! Int
        self.firstName <- dictionary.property("first_name")
        self.lastName <- dictionary.property("last_name")
        self.about <- dictionary.property("about")
        self.city <- dictionary.property("city")
        self.url <- dictionary.property("url")
        self.photo <- dictionary.property("photo_url")
    }
}
