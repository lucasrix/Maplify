//
//  Notification.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import Tailor

class Notification: Model {
    dynamic var message = ""
    dynamic var unread: Bool = false
    dynamic var notificable_type = ""
    dynamic var action_user: User! = nil
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id <- map.property("id")
        self.message <- map.property("message")
        self.unread <- map.property("unread")
        self.notificable_type <- map.property("notificable_type")
        self.action_user <- map.relation("action_user")
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}
