//
//  StoryCreateManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/14/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

protocol StoryCreateManagerDelegate {
    func creationStoryDidSuccess(storyId: Int)
    func creationStoryDidFail(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!)
    func creationStoryPointDidStartCreating(draft: StoryPointDraft)
    func creationStoryPointDidSuccess(draft: StoryPointDraft)
    func creationStoryPointDidFail(draft: StoryPointDraft)
    func allOperationsCompleted(storyId: Int)
}

class StoryCreateManager: NSObject {
    static let sharedManager = StoryCreateManager()
    
    var imageManager = PHCachingImageManager()
    var delegate: StoryCreateManagerDelegate! = nil
    
    func postStory(storyName: String, storyDescription: String!, storyPointDrafts: [StoryPointDraft]) {
            var params: [String: AnyObject] = ["name": storyName, "discoverable": false]
            if storyDescription.characters.count > 0 {
                params["description"] = storyDescription
            }
            
            ApiClient.sharedClient.createStory(params, success: { [weak self] (response) in
                let story = response as! Story
                StoryManager.saveStory(story)
                self?.delegate?.creationStoryDidSuccess(story.id)
                self?.postStoryPoints(story.id, drafts: storyPointDrafts)
                
                }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                    self?.delegate?.creationStoryDidFail(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
    }
    
    func retryPostStoryPoint(draft: StoryPointDraft, storyId: Int, completion: ((draft: StoryPointDraft, success: Bool) -> ())!) {
        FileDataManager.fileDataForDraft(draft, targetSize: self.targetSize()) { (fileData, params, kind) in
            if fileData != nil {
                self.retryPostAttachment(fileData!, params: params, kind: kind, completion: { [weak self] (success, attachmentId) in
                    if success == true {
                        self?.retryPostStoryPointRemote(draft, kind: kind, storyId: storyId, attachmentId: attachmentId, completion: completion)
                    } else {
                        completion?(draft: draft, success: false)
                    }
                })
            } else {
                completion?(draft: draft, success: false)
            }
        }
    }
    
    private func postStoryPoints(storyId: Int, drafts: [StoryPointDraft]) {
        for draft in drafts {
            OperationQueueManager.sharedInstance.addOperation({ [weak self] (operation) in
                self?.delegate?.creationStoryPointDidStartCreating(draft)
                self?.fileDataForDraft(draft, operation: operation, completion: { (fileData, params, kind, operation) in
                    self?.remotePostAttachment(draft, fileData: fileData, params: params, kind: kind, operation: operation, storyId: storyId)
                })
            })
        }
        
        OperationQueueManager.sharedInstance.addOperation { (operation) in
            ApiClient.sharedClient.getStory(storyId, success: { [weak self] (response) in
                StoryManager.saveStory(response as! Story)
                operation.completeOperation()
                if OperationQueueManager.sharedInstance.queue.operationCount == 0 {
                    self?.delegate?.allOperationsCompleted(storyId)
                }
                
                }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                    operation.completeOperation()
                    if OperationQueueManager.sharedInstance.queue.operationCount == 0 {
                        self?.delegate?.allOperationsCompleted(storyId)
                    }
            })
        }
    }
    
    private func remotePostAttachment(draft: StoryPointDraft, fileData: NSData, params: [String: AnyObject], kind: StoryPointKind, operation: NetworkOperation, storyId: Int) {
        if draft.readyToCreate() {
            ApiClient.sharedClient.postAttachment(fileData, params: params, success: { [weak self] (response) -> () in
                let attachmentID = (response as! Attachment).id
                self?.remotePostStoryPoint(draft, kind: kind, storyId: storyId, attachmentId: attachmentID, operation: operation)
                
            }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.delegate?.creationStoryPointDidFail(draft)
                operation.completeOperation()
            }
        } else {
            self.delegate?.creationStoryPointDidFail(draft)
            operation.completeOperation()
        }
    }
    
    private func remotePostStoryPoint(draft: StoryPointDraft, kind: StoryPointKind, storyId: Int, attachmentId: Int, operation: NetworkOperation) {
        self.paramsForDraft(draft, kind: kind, attachmentId: attachmentId, storyId: storyId) { (params) in
            ApiClient.sharedClient.createStoryPoint(params, success: { [weak self] (response) in
                StoryPointManager.saveStoryPoint(response as! StoryPoint)
                self?.delegate.creationStoryPointDidSuccess(draft)
                operation.completeOperation()
                
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.delegate?.creationStoryPointDidFail(draft)
                operation.completeOperation()
            }
        }
    }
    
    private func paramsForDraft(draft: StoryPointDraft, kind: StoryPointKind, attachmentId: Int, storyId: Int, completion: ((params: [String: AnyObject]) -> ())) {
        var locationDict: [String: AnyObject] = ["latitude":draft.coordinate.latitude, "longitude":draft.coordinate.longitude, "address": draft.address]
        var storyPointDict: [String: AnyObject] = ["kind":kind.rawValue,
                                                   "text":draft.storyPointDescription,
                                                   "attachment_id":attachmentId,
                                                   "story_ids":[storyId]]
        if draft.address.characters.count > 0 {
            locationDict["address"] =  draft.address
            storyPointDict["location"] = locationDict
            completion(params: storyPointDict)
        } else {
            GeocoderHelper.placeFromCoordinate(draft.coordinate, completion: { (addressString) in
                locationDict["address"] =  addressString
                storyPointDict["location"] = locationDict
                completion(params: storyPointDict)
            })
        }
    }
    
    private func fileDataForDraft(draft: StoryPointDraft, operation: NetworkOperation, completion: ((fileData: NSData, params: [String: AnyObject], kind: StoryPointKind, operation: NetworkOperation) -> ())!) {
        FileDataManager.fileDataForDraft(draft, targetSize: self.targetSize()) { (fileData, params, kind) in
            if fileData != nil {
                completion?(fileData: fileData, params: params, kind: kind, operation: operation)
            } else {
                self.delegate?.creationStoryPointDidFail(draft)
                operation.completeOperation()
            }
        }
    }
    
    // MARK: - retry posting
    private func retryPostStoryPointRemote(draft: StoryPointDraft, kind: StoryPointKind, storyId: Int, attachmentId: Int, completion: ((draft: StoryPointDraft, success: Bool) -> ())!) {
        if draft.readyToCreate() {
            let locationDict: [String: AnyObject] = ["latitude":draft.coordinate.latitude, "longitude":draft.coordinate.longitude, "address": draft.address]
            let storyPointDict: [String: AnyObject] = ["kind":kind.rawValue,
                                                       "text":draft.storyPointDescription,
                                                       "location":locationDict,
                                                       "attachment_id":attachmentId,
                                                       "story_ids":[storyId]]
            
            ApiClient.sharedClient.createStoryPoint(storyPointDict, success: { (response) in
                StoryPointManager.saveStoryPoint(response as! StoryPoint)
                completion?(draft: draft, success: true)
            }) { (statusCode, errors, localDescription, messages) in
                completion?(draft: draft, success: false)
            }
        } else {
            completion?(draft: draft, success: false)
        }
    }
    
    private func retryPostAttachment(fileData: NSData, params: [String: AnyObject], kind: StoryPointKind, completion: ((success: Bool, attachmentId: Int) -> ())!){
        ApiClient.sharedClient.postAttachment(fileData, params: params, success: { (response) in
            let attachment = response as! Attachment
            completion?(success: true, attachmentId: attachment.id)
        }) { (statusCode, errors, localDescription, messages) in
            completion?(success: false, attachmentId: 0)
        }
    }
    
    private func targetSize() -> CGSize {
        let imageWidth = UIScreen().screenWidth() * UIScreen().screenScale()
        return CGSizeMake(imageWidth, imageWidth)
    }
}