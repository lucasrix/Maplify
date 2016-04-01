//
//  Story.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift 
import Tailor

class Story: Model {
    dynamic var user: User! = nil
    dynamic var title = ""
    dynamic var storyDescription = ""
    dynamic var discoverable: Bool = false
    let storyPoints = List<StoryPoint>()
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id <- map.property("id")
        self.title <- map.property("name")
        self.storyDescription <- map.property("description")
        self.discoverable <- map.property("discoverable")
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}
