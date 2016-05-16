//
//  NotificationUser.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import Tailor

class NotificationUser: Notification {
    dynamic var notificable: User! = nil
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()

        self.notificable <- map.relation("notificable")
    }
}
