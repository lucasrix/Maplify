//
//  NotificationsManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import Tailor

class NotificationsManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        return response
    }
    
    class func saveNotificationItems(notificationItems: [String: AnyObject]) {
        let list: NSArray = notificationItems["notifications"] as! NSArray
        print(list)
        for notificationItem in list {
            let dict = notificationItem as! [String: AnyObject]
            let type: String = dict.property("notificable_type")!
            if type == "User" {
                let notification = NotificationUser(dict)
                NotificationsManager.saveNotification(notification)
            } else if type == "StoryPoint" {
                let notification = NotificationStoryPoint(dict)
                NotificationsManager.saveNotification(notification)
            } else if type == "Story" {
                let notification = NotificationStory(dict)
                NotificationsManager.saveNotification(notification)
            }
        }
    }
    
    class func saveNotification(item: Notification) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(item, update: true)
        }
    }
}
