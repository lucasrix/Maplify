//
//  StoryPoint.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import RealmSwift

public enum StoryPointKind: String {
    case Audio = "audio"
    case Video = "video"
    case Photo = "photo"
    case Text = "text"
}

class StoryPoint: Model {
    dynamic var user: User! = nil
    dynamic var story: Story! = nil
    dynamic var location: Location! = nil
    dynamic var attachment: Attachment! = nil
    dynamic var kind = ""
    dynamic var caption = ""
    dynamic var text = ""
    dynamic var liked: Bool = false
    dynamic var reported: Bool = false
    var discoverItem: DiscoverItem? {
        return self.linkingObjects(DiscoverItem.self, forProperty: "storyPoint").first
    }
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id <- map.property("id")
        self.user <- map.relationOrNil("user")
        self.location <- map.relationOrNil("location")
        self.kind <- map.property("kind")
        self.caption <- map.property("caption")
        self.attachment <- map.relationOrNil("attachment")
        self.text <- map.property("text")
        self.created_at <- map.property("created_at")
        self.updated_at <- map.property("updated_at")
        self.liked <- map.property("liked")
        self.reported <- map.property("reported")
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}
