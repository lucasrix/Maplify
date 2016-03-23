//
//  StoryPointManager.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class StoryPointManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let dictionary = (response["story_point"] != nil) ? (response["story_point"] as! [String : AnyObject]) : response
        return StoryPoint(dictionary)
    }
}