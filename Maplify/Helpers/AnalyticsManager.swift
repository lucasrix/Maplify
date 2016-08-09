//
//  MixpanelManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 8/8/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Mixpanel
import Foundation

protocol AnalyticsManagerProtocol {
    func trackSignUp(user: User)
    func trackViewStorypoint(storypoint: StoryPoint)
    func trackViewStory(story: Story)
    func trackCreateStorypoint(storypoint: StoryPoint)
    func trackCreateStory(story: Story)
    func updateUserDataIfNeeded()
}

class AnalyticsManager {

}
