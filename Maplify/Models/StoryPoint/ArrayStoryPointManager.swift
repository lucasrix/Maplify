//
//  ArrayStoryPointManager.swift
//  Maplify
//
//  Created by Sergey on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class ArrayStoryPointManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let storyPointsArray: [StoryPoint]? = response.relations("preview_story_points")
        return storyPointsArray
    }
}