//
//  StoryPointManager.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import RealmSwift

class StoryPointManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let dictionary = (response["story_point"] != nil) ? (response["story_point"] as! [String : AnyObject]) : response
        return StoryPoint(dictionary)
    }
    
    class func saveStoryPoints(storyPoints: [StoryPoint]!) {
        for storyPoint in storyPoints {
            self.saveStoryPoint(storyPoint)
        }
    }
    
    class func saveStoryPoint(storyPoint: StoryPoint) {
        let realm = try! Realm()

        let recordExists = (realm.objectForPrimaryKey(StoryPoint.self, key: storyPoint.id) != nil)
        try! realm.write {
            realm.add(storyPoint, update: recordExists)
        }
    }
    
    class func find(storyPointId: Int) -> StoryPoint! {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(StoryPoint.self, key: storyPointId)
    }
    
    class func delete(storyPointId: Int) {
        let realm = try! Realm()
        let storyPoint = realm.objectForPrimaryKey(StoryPoint.self, key: storyPointId)
        if storyPoint != nil {
            try! realm.write {
                realm.delete(storyPoint!)
            }
        }
    }
    
    class func delete(storyPoint: StoryPoint) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(storyPoint)
        }
    }
}