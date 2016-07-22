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
        for storyPointDraft in storyPointDrafts {
            OperationQueueManager.sharedInstance.addOperation({ [weak self] (operation) in
                self?.delegate?.updatingStoryPointDidStartCreating(storyPointDraft)
                let params = self?.paramsForDraft(storyPointDraft)
                
                ApiClient.sharedClient.updateStoryPoint(storyPointDraft.id, params: params!, success: { [weak self] (response) -> () in
                    StoryPointManager.saveStoryPoint(response as! StoryPoint)
                    self?.delegate?.updatingStoryPointDidSuccess(storyPointDraft)
                    operation.completeOperation()
                    
                }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
                    self?.delegate.updatingStoryPointDidFail(storyPointDraft)
                    operation.completeOperation()
                }
            })
        }
        
        OperationQueueManager.sharedInstance.addOperation { (operation) in
            let storyPointIds = storyPointDrafts.map({$0.id})
            let params: [String: AnyObject] = ["name": storyName, "description": storyDescription, "discoverable": true, "story_point_ids": storyPointIds]
            ApiClient.sharedClient.updateStory(storyId, params: params, success: { [weak self] (response) in
                let story = response as! Story
                StoryManager.saveStory(story)
                self?.delegate?.updatingStoryDidSuccess(story.id)
                operation.completeOperation()
                self?.checkAllOperationsCompleted(storyId)
                
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                operation.completeOperation()
                self?.checkAllOperationsCompleted(storyId)
                self?.delegate?.updatingStoryDidFail(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        }
    }
    
    private func checkAllOperationsCompleted(storyId: Int) {
        if OperationQueueManager.sharedInstance.queue.operationCount == 0 {
            self.delegate?.allOperationsCompleted(storyId)
        }
    }
    
    private func paramsForDraft(draft: StoryPointDraft) -> [String: AnyObject] {
        let locationDict: [String: AnyObject] = ["latitude": draft.coordinate.latitude,
                                                 "longitude": draft.coordinate.longitude,
                                                 "address": draft.address]
        let storyPointDict: [String: AnyObject] = ["kind": draft.storyPointKind,
                                                   "text": draft.storyPointDescription,
                                                   "location": locationDict,
                                                   "story_ids": draft.storiesIds]
        return storyPointDict
    }
}
