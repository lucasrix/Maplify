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
    
    class func deleteLinksFromStory(storyId: Int) {
        let realm = try! Realm()
        
        let result = realm.objects(StoryPoint.self).filter{ (storyPoint) -> Bool in
            let links = Converter.listToArray(storyPoint.storiesLinks, type: StoryLink.self).map({$0.id})
            return links.contains(storyId)
        }
        
        let story = StoryManager.find(storyId)
        if story != nil {
            for storyPoint in result {
                StoryPointManager.deleteLink(storyPoint, storyId: storyId)
            }
        }
    }
    
    class func deleteLink(storyPoint: StoryPoint, storyId: Int) {
        let realm = try! Realm()
        
        let storiesLinksIds = Converter.listToArray(storyPoint.storiesLinks, type: StoryLink.self).map({$0.id})
        
        let index = storiesLinksIds.indexOf(storyId)
        if index != NSNotFound {
            try! realm.write {
                storyPoint.storiesLinks.removeAtIndex(index!)
            }
        }
    }
    
    class func userStoryPoints(sorted: String, ascending: Bool) -> [StoryPoint] {
        let realm = try! Realm()
        let userId = SessionManager.currentUser().id
        let storyPoints = Array(realm.objects(StoryPoint).filter("user.id == \(userId)").sorted(sorted, ascending: ascending))
        return storyPoints
    }
    
    class func allStoryPoints() -> [StoryPoint] {
        let realm = try! Realm()
        return Array(realm.objects(StoryPoint).filter("reported == false").sorted("created_at", ascending: false))
    }
    
    class func allStoryPoints(limit: Int) -> [StoryPoint] {
        let array = StoryPointManager.allStoryPoints()
        return Array(array.prefix(limit))
    }
}