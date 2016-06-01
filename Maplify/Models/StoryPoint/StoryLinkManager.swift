//
//  StoryLinkManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class StoryLinkManager: ModelManager {
    class func deleteStoryLink(storyId: Int) {
        let realm = try! Realm()
        if let storyLink = Array(realm.objects(StoryLink).filter("id == \(storyId)")).first {
            try! realm.write {
                realm.delete(storyLink)
            }
        }
    }
}