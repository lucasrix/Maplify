//
//  Story.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift 
import Tailor

class Story: Model {
    dynamic var user: User! = nil
    dynamic var title = ""
    dynamic var storyDescription = ""
    let storyPoints = List<StoryPoint>()
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        //TODO:
    }
}
