//
//  Account.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class Profile: Model {
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var photo = ""
    dynamic var city = ""
    dynamic var url = ""
    dynamic var about = ""
    dynamic var story_points_count: Int = 0
    dynamic var stories_count: Int = 0
    dynamic var followers_count: Int = 0
    dynamic var followings_count: Int = 0
    dynamic var likes_count: Int = 0
    dynamic var saves_count: Int = 0


    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id <- map.property("id")
        self.firstName <- map.property("first_name")
        self.lastName <- map.property("last_name")
        self.about <- map.property("about")
        self.city <- map.property("city")
        self.url <- map.property("url")
        self.photo <- map.property("photo_url")
        self.story_points_count <- map.property("story_points_count")
        self.stories_count <- map.property("stories_count")
        self.followers_count <- map.property("followers_count")
        self.followings_count <- map.property("followings_count")
        self.likes_count <- map.property("likes_count")
        self.saves_count <- map.property("saves_count")
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}
