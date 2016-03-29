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
    
    class func saveStory(story: Story) {
        let realm = try! Realm()
        
        let recordExists = (realm.objectForPrimaryKey(Story.self, key: story.id) != nil)
        try! realm.write {
            realm.add(story, update: recordExists)
        }
    }
}