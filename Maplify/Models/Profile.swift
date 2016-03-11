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
    dynamic var homeCity = ""
    dynamic var personalUrl = ""
    dynamic var about = ""

    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        let profileDict = map["profile"] as! [String : AnyObject]
        
        self.id = profileDict["id"] as! Int
        self.firstName <- profileDict.property("first_name")
        self.lastName <- profileDict.property("last_name")
        self.about <- profileDict.property("about")
        self.photo <- profileDict.property("photo_url")
    }
}
