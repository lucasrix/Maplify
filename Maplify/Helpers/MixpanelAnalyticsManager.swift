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
        let properties: [String: AnyObject] = ["User ID": user.id,
                                               "First Name": (user.profile?.firstName)!,
                                               "Last Name": (user.profile?.lastName)!,
                                               "Signup Date": NSDate(),
                                               "Email": user.email,
                                               "Location": user.profile.location.city]
        Mixpanel.sharedInstance().track("Completed Sign Up", properties: properties)
        self.updateUserDataIfNeeded()
    }
    
    func trackViewStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Storypoint ID": storypoint.id,
                                               "Storypoint Title": storypoint.caption,
                                               "Created By": storypoint.user.profile.firstName + " " + storypoint.user.profile.lastName,
                                               "Location": storypoint.location.address]
        Mixpanel.sharedInstance().track("View sP", properties: properties)
        Mixpanel.sharedInstance().people.increment("Total of View sP", by: 1)
    }
    
    func trackViewStory(story: Story) {
        let properties: [String: AnyObject] = ["Story ID": story.id,
                                               "Story Title": story.title,
                                               "Created By": story.user.profile.firstName + " " + story.user.profile.lastName]
        Mixpanel.sharedInstance().track("View story", properties: properties)
        Mixpanel.sharedInstance().people.increment("Total of View story", by: 1)
    }
    
    func trackCreateStorypoint(storypoint: StoryPoint) {
        let properties: [String: AnyObject] = ["Storypoint ID": storypoint.id,
                                               "Storypoint Title": storypoint.caption,
                                               "Created By": storypoint.user.profile.firstName + " " + storypoint.user.profile.lastName,
                                               "Media Type": storypoint.kind]
        Mixpanel.sharedInstance().track("Create sP", properties: properties)
        Mixpanel.sharedInstance().people.increment("Total of Create sP", by: 1)
    }
    
    func trackCreateStory(story: Story) {
        let properties: [String: AnyObject] = ["Story ID": story.id,
                                               "Story Title": story.title,
                                               "Created By": story.user.profile.firstName + " " + story.user.profile.lastName]
        Mixpanel.sharedInstance().track("Create story", properties: properties)
        Mixpanel.sharedInstance().people.increment("Total of Create story", by: 1)
    }
    
    func updateUserDataIfNeeded() {
        if (SessionHelper.sharedHelper.isSessionTokenExists()) && (SessionManager.currentUser() != nil) {
            let user = SessionManager.currentUser()
            let mixpanel = Mixpanel.sharedInstance()
            mixpanel.identify(String(SessionManager.currentUser().id))
            mixpanel.people.set("User ID", to: user.id)
            mixpanel.people.set("First Name", to: user.profile.firstName)
            mixpanel.people.set("Last Name", to: user.profile.lastName)
            mixpanel.people.set("Email", to: user.email)
            mixpanel.people.set("City", to: (user.profile.location?.city)!)
        }
    }
}
