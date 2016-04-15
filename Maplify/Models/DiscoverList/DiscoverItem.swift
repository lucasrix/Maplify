//
//  DiscoverItem.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/13/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import Tailor

public enum DiscoverItemType : Int {
    case StoryPoint = 0
    case Story
}

class DiscoverItem: Model {
    dynamic var type: Int = 0
    dynamic var storyPoint: StoryPoint? = nil
    dynamic var story: Story? = nil
    dynamic var nearMePosition: Int = 0
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
//        if map.property("type") == String(StoryPoint) {
//            self.type = DiscoverItemType.StoryPoint.rawValue
//        } else if map.property("type") == String(Story) {
//            self.type = DiscoverItemType.Story.rawValue
//        }
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}

extension DiscoverItem {
    func nextId() -> Int{
        let realm = try! Realm()
        var nextId: Int = 0
        let objects = realm.objects(DiscoverItem).sorted("id")
        if objects.count > 0 {
            let lastId: Int = objects.last!.id
            nextId = lastId + 1
        }
        return nextId
    }
}
