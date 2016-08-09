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
        let properties: [String: AnyObject] = ["User ID": user.id,
                                               "First Name": (user.profile?.firstName)!,
                                               "Last Name": (user.profile?.lastName)!,
                                               "Signup Date": NSDate(),
                                               "Email": user.email,
                                               "Location": user.profile.location.city]
        print(properties)
    }
    
    func trackViewStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Storypoint ID": storypoint.id,
                                               "Storypoint Title": storypoint.caption,
                                               "Created By": storypoint.user.profile.firstName + " " + storypoint.user.profile.lastName,
                                               "Location": storypoint.location.address]
        print(properties)
    }
    
    func trackViewStory(story: Story) {
        let properties: [String: AnyObject] = ["Story ID": story.id,
                                               "Story Title": story.title,
                                               "Created By": story.user.profile.firstName + " " + story.user.profile.lastName]
        print(properties)
    }
    
    func trackCreateStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Storypoint ID": storypoint.id,
                                               "Storypoint Title": storypoint.caption,
                                               "Created By": storypoint.user.profile.firstName + " " + storypoint.user.profile.lastName,
                                               "Media Type": storypoint.kind]
        print(properties)
    }
    
    func trackCreateStory(story: Story) {
        let properties: [String: AnyObject] = ["Story ID": story.id,
                                               "Story Title": story.title,
                                               "Created By": story.user.profile.firstName + " " + story.user.profile.lastName]
        print(properties)
    }
}