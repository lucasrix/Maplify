//
//  DiscoverItemManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class DiscoverItemManager: ModelManager {
    
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        return response
    }
    
    class func saveDiscoverListItems(discoverItems: [String: AnyObject], pageNumber: Int, itemsCountInPage: Int, searchLocationParameter: SearchLocationParameter) {
        let list: NSArray = discoverItems["discovered"] as! NSArray
        var currentPosition = (pageNumber - 1) * itemsCountInPage
        for item in list {
            currentPosition += 1
            var discoverItem: DiscoverItem! = nil
            if item["type"] as! String == String(StoryPoint) {
                let dict = item as! [String: AnyObject]
                
                let storyPoint = StoryPoint(dict)
                discoverItem = findOrCreateWithStoryPoint(storyPoint)
            
            } else if item["type"] as! String == String(Story) {
                let dict = item as! [String: AnyObject]

                let story = Story(dict)
                discoverItem = findOrCreateWithStory(story)
            }
            
            let realm = try! Realm()
            realm.beginWrite()
            if searchLocationParameter == SearchLocationParameter.NearMe {
                discoverItem.nearMePosition = currentPosition
            } else if searchLocationParameter == SearchLocationParameter.AllOverTheWorld {
                discoverItem.allOverTheWorldPosition = currentPosition
            } else if searchLocationParameter == SearchLocationParameter.ChoosenPlace {
                discoverItem.choosenPlacePosition = currentPosition
            }
            try! realm.commitWrite()
            DiscoverItemManager.saveItem(discoverItem)
        }
    }
    
    class func find(DiscoverItemId: Int) -> DiscoverItem! {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(DiscoverItem.self, key: DiscoverItemId)
    }
    
    class func findWithStoryPoint(storyPointId: Int) -> DiscoverItem! {
        let realm = try! Realm()
        return realm.objects(DiscoverItem).filter("storyPoint.id == \(storyPointId)").first
    }
    
    class func findOrCreateWithStoryPoint(storyPoint: StoryPoint) -> DiscoverItem! {
        let realm = try! Realm()
        if let foundedObject = realm.objects(DiscoverItem).filter("storyPoint.id == \(storyPoint.id)").first {
            return foundedObject
        } else {
            let newObject = DiscoverItem()
            newObject.type = DiscoverItemType.StoryPoint.rawValue
            StoryPointManager.saveStoryPoint(storyPoint)
            newObject.storyPoint = storyPoint
            newObject.id = newObject.nextId()
            return newObject
        }
    }
    
    class func findOrCreateWithStory(story: Story) -> DiscoverItem! {
        let realm = try! Realm()
        if let foundedObject = realm.objects(DiscoverItem).filter("story.id == \(story.id)").first {
            return foundedObject
        } else {
            let newObject = DiscoverItem()
            newObject.type = DiscoverItemType.Story.rawValue
            StoryManager.saveStory(story)
            newObject.story = story
            newObject.id = newObject.nextId()
            return newObject
        }
    }
    
    class func saveItem(item: DiscoverItem) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(item, update: true)
        }
    }
    
    class func delete(discoverItemId: Int) {
        let realm = try! Realm()
        let discoverItem = realm.objectForPrimaryKey(DiscoverItem.self, key: discoverItemId)
        if discoverItem != nil {
            try! realm.write {
                realm.delete(discoverItem!)
            }
        }
    }
    
    class func delete(discoverItem: DiscoverItem) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(discoverItem)
        }
    }
}
