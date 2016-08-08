//
//  MixpanelAnalyticsManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 8/8/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Mixpanel
import Foundation

class MixpanelAnalyticsManager: AnalyticsManagerProtocol {
    func trackSignUp(user: User) {
        let properties: [String: AnyObject] = ["user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "account_create_date": NSDate(),
                                               "email": user.email]
        Mixpanel.sharedInstance().track("User signup test", properties: properties)
    }
    
    func trackViewStorypoint(user: User, storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "storypoint_id": storypoint.id,
                                               "storypoint_title": storypoint.caption]
        Mixpanel.sharedInstance().track("View storypoint test", properties: properties)
    }
    
    func trackViewStory(user: User, story: Story) {
        let properties: [String: AnyObject] = ["user_id": user.id,
                                               "first_name": (user.profile?.firstName)!,
                                               "last_name": (user.profile?.lastName)!,
                                               "story_id": story.id,
                                               "story_title": story.title]
        Mixpanel.sharedInstance().track("View story test", properties: properties)
    }
    
    func trackCreateStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["user_id": storypoint.user.id,
                                               "first_name": (storypoint.user.profile?.firstName)!,
                                               "last_name": (storypoint.user.profile?.lastName)!,
                                               "storypoint_id": storypoint.id,
                                               "storypoint_title": storypoint.caption,
                                               "storypoint_description": storypoint.text]
        Mixpanel.sharedInstance().track("Create storypoint test", properties: properties)
    }
    
    func trackCreateStory(story: Story) {
        let properties: [String: AnyObject] = ["user_id": story.user.id,
                                               "first_name": (story.user.profile?.firstName)!,
                                               "last_name": (story.user.profile?.lastName)!,
                                               "story_id": story.id,
                                               "story_title": story.title,
                                               "story_description": story.storyDescription]
        Mixpanel.sharedInstance().track("Create story test", properties: properties)
    }
}
