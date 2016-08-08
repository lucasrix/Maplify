//
//  ConsoleAnalyticsManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 8/8/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ConsoleAnalyticsManager: AnalyticsManagerProtocol {
    func trackSignUp(user: User) {
        let properties: [String: AnyObject] = ["Event": "User signup",
                                               "user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "account_create_date": NSDate(),
                                               "email": user.email]
        print(properties)
    }
    
    func trackViewStorypoint(user: User, storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Event": "View storypoint",
                                               "user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "storypoint_id": storypoint.id,
                                               "storypoint_title": storypoint.caption]
        print(properties)
    }
    
    func trackViewStory(user: User, story: Story) {
        let properties: [String: AnyObject] = ["Event": "View story",
                                               "user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "story_id": story.id,
                                               "story_title": story.title]
        print(properties)
    }
    
    func trackCreateStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Event": "Create storypoint",
                                               "user_id": storypoint.user.id,
                                               "first_name": (storypoint.user.profile?.firstName)!,
                                               "last_name": (storypoint.user.profile?.lastName)!,
                                               "storypoint_id": storypoint.id,
                                               "storypoint_title": storypoint.caption,
                                               "storypoint_description": storypoint.text]
        print(properties)
    }
    
    func trackCreateStory(story: Story) {
        let properties: [String: AnyObject] = ["Event": "Create story",
                                               "user_id": story.user.id,
                                               "first_name": (story.user.profile?.firstName)!,
                                               "last_name": (story.user.profile?.lastName)!,
                                               "story_id": story.id,
                                               "story_title": story.title,
                                               "story_description": story.storyDescription]
        print(properties)
    }
}