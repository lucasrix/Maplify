//
//  CaptureDataFetchingExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

let kCaptureStorypointsFetchLimit: Int = 180

extension CaptureViewController {
    
    // MARK: - database
    func loadLocalAllStoryPoints() {
        self.currentStoryPoints = StoryPointManager.allStoryPoints(kCaptureStorypointsFetchLimit)
    }
    
    func loadLocalCurrentStoryPont(storyPointId: Int) {
        self.currentStoryPoints.removeAll()
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint != nil {
            self.currentStoryPoints.append(StoryPointManager.find(storyPointId))
        } else {
            self.showNotFoundPostError()
        }
    }
    
    func loadLocalCurrentStory(storyId: Int) {
        self.currentStoryPoints.removeAll()
        self.currentStory = StoryManager.find(storyId)
        if self.currentStory?.storyPoints.count == 0 {
            self.popController()
        }
        if self.currentStory != nil {
            self.currentStoryPoints.appendContentsOf(Converter.listToArray(self.currentStory.storyPoints, type: StoryPoint.self))
        } else {
            self.showNotFoundPostError()
        }
    }
    
    func showNotFoundPostError() {
        let message = NSLocalizedString("Alert.PostNotFound", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(nil, message: message, cancel: cancel, handle: { (action) in
            self.cancelButtonTapped()
        })
    }
    
    // MARK: - remote
    func loadRemoteAllStoryPoints(completion: ((success: Bool) -> ())!) {
        ApiClient.sharedClient.getAllStoryPoints({ (response) in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let storyPoints = response as! [StoryPoint]
                StoryPointManager.saveStoryPoints(storyPoints)
                StoryPointManager.deleteNonExisting(storyPoints.map({$0.id}))
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(success: true)
                })
            })
        }, failure:  { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        })
    }
    
    func loadRemoteStoryPoint(storyPointId: Int, completion: ((success: Bool) -> ())!) {
        ApiClient.sharedClient.getStoryPoint(storyPointId, success: { (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            completion(success: true)
            
            }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                completion(success: false)
            })
    }
    
    func loadRemoteStory(storyId: Int, completion: ((success: Bool) -> ())!) {
        ApiClient.sharedClient.getStory(storyId, success: { (response) in
            StoryManager.saveStory(response as! Story)
            completion(success: true)
            
        }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        })
    }
}
