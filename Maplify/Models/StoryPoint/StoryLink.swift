//
//  StoryLink.swift
//  Maplify
//
//  Created by jowkame on 5/29/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class StoryLink: Model {
    dynamic var name = String()
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.id <- map.property("id")
        self.name <- map.property("name")
    }
}