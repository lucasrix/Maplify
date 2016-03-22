//
//  StoryPoint.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class StoryPoint: Model {
    dynamic var user: User! = nil
    dynamic var story: Story! = nil
    dynamic var location: Location! = nil
    dynamic var attachment: Attachment! = nil
    dynamic var kind = ""
    dynamic var caption = ""
    dynamic var storyPointDescription = ""
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        let storyPointDict = map["story_point"] as! [String : AnyObject]
        
        self.id <- storyPointDict.property("id")
        self.user <- map.relation("story_point")
        self.location <- storyPointDict.relation("location")
        self.kind <- storyPointDict.property("kind")
        self.caption <- storyPointDict.property("caption")
        self.attachment <- storyPointDict.relation("attachment")
        print("")
    }
}
