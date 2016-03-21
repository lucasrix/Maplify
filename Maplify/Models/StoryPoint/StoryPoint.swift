//
//  StoryPoint.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import CoreLocation

class StoryPoint: Model {
    dynamic var user: User! = nil
    dynamic var story: Story! = nil
    dynamic var location: CLLocation! = nil
    dynamic var locationTitle = ""
    dynamic var title = ""
    dynamic var storyPointDescription = ""
    dynamic var file = ""
    dynamic var type = ""
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        //TODO:
    }
}
