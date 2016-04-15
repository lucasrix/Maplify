//
//  StoryManager.swift
//  Maplify
//
//  Created by Sergey on 3/29/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class StoryManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let dictionary = (response["story"] != nil) ? (response["story"] as! [String : AnyObject]) : response
        return Story(dictionary)
    }
    
    class func saveStories(stories: [Story]) {
        let realm = try! Realm()
        
        for story in stories {
            try! realm.write {
                realm.add(story, update: true)
            }
        }
    }
    
    class func saveStoriesAndReturn(stories: [Story]) -> [Story] {
        var items: [Story] = []
        for story in stories {
            self.saveStory(story)
            items.append(self.find(story.id))
        }
        return items
    }
    
    class func saveStory(story: Story) {
        let realm = try! Realm()
        
        let storyPoints = Converter.listToArray(story.storyPoints, type: StoryPoint.self)
        StoryPointManager.saveStoryPoints(storyPoints)
        
        let recordExists = (realm.objectForPrimaryKey(Story.self, key: story.id) != nil)
        try! realm.write {
            realm.add(story, update: recordExists)
        }
    }
    
    class func find(storyId: Int) -> Story! {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(Story.self, key: storyId)
    }
    
    class func saveAndReturnStory(story: Story) -> Story {
        self.saveStory(story)
        return self.find(story.id)
    }
}