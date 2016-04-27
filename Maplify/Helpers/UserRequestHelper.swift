//
//  UserRequestHelper.swift
//  Maplify
//
//  Created by Sergei on 26/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class UserRequestResponseHelper {
    class func sortAndMerge(storyPoints: [StoryPoint], stories: [Story]) {
        
        for story in stories {
            if story.storyPoints.count > 0 {
                let discoverItem = DiscoverItemManager.findOrCreateWithStory(story)
                DiscoverItemManager.saveItem(discoverItem)
            }
        }
        
        for storyPoint in storyPoints {
            let discoverItem = DiscoverItemManager.findOrCreateWithStoryPoint(storyPoint)
            DiscoverItemManager.saveItem(discoverItem)
        }
    }
}