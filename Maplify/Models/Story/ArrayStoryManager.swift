//
//  ArrayStoryManager.swift
//  Maplify
//
//  Created by jowkame on 31.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class ArrayStoryManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let storiesArray: [Story]? = response.relations("stories")
        return storiesArray
    }
}