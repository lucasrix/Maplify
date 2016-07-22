//
//  StoryUpdateManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

protocol StoryUpdateManagerDelegate {
    func updatingStoryDidSuccess(storyId: Int)
    func updatingStoryDidFail(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!)
    func updatingStoryPointDidStartCreating(draft: StoryPointDraft)
    func updatingStoryPointDidSuccess(draft: StoryPointDraft)
    func updatingStoryPointDidFail(draft: StoryPointDraft)
    func allOperationsCompleted(storyId: Int)
}

class StoryUpdateManager: NSObject {
    static let sharedManager = StoryUpdateManager()
    
    var delegate: StoryUpdateManagerDelegate! = nil
    
    func updateStory(storyId: Int, storyName: String, storyDescription: String, storyPointDrafts: [StoryPointDraft]) {
        
        
        let params: [String: AnyObject] = ["name": storyName, "description": storyDescription, "discoverable": true, "story_point_ids": storyPointDrafts.map({$0.id})]
        ApiClient.sharedClient.updateStory(storyId, params: params, success: { [weak self] (response) in
            let story = response as! Story
            StoryManager.saveStory(story)
            self?.delegate?.updatingStoryDidSuccess(story.id)

            // add storypoints updating
            
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.delegate?.updatingStoryDidFail(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
}
