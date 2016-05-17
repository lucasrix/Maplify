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
        for notificationItem in list {
            let dict = notificationItem as! [String: AnyObject]
            let notification = Notification(dict)
            let notificableDict: [String: AnyObject]! = dict.property("notificable")
            if notificableDict != nil {
                let type: String = dict.property("notificable_type")!
                if type == NotificableType.User.rawValue {
                    notification.notificable_user = User(notificableDict)
                    NotificationsManager.saveNotification(notification)
                } else if type == NotificableType.StoryPoint.rawValue {
                    notification.notificable_storypoint = StoryPoint(notificableDict)
                    NotificationsManager.saveNotification(notification)
                } else if type == NotificableType.Story.rawValue {
                    notification.notificable_story = Story(notificableDict)
                    NotificationsManager.saveNotification(notification)
                }
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
