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
    
    class func saveStoryPointsAndReturn(storyPoints: [StoryPoint]!) -> [StoryPoint] {
        var items: [StoryPoint] = []
        for storyPoint in storyPoints {
            self.saveStoryPoint(storyPoint)
            items.append(self.find(storyPoint.id))
        }
        return items
    }
    
    class func saveStoryPointAndReturn(storyPoint: StoryPoint!) -> StoryPoint {
        self.saveStoryPoint(storyPoint)
        return self.find(storyPoint.id)
    }
    
    class func saveStoryPoint(storyPoint: StoryPoint) {
        let realm = try! Realm()

        try! realm.write {
            realm.add(storyPoint, update: true)
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