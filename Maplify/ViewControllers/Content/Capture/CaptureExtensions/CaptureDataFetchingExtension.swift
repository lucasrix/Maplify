//
//  CaptureDataFetchingExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

let kCaptureStorypointsFetchLimit: Int = 200

extension CaptureViewController {
    
    // MARK: - database
    func loadLocalAllStoryPonts() {
        self.currentStoryPoints = StoryPointManager.allStoryPoints(kCaptureStorypointsFetchLimit)
    }
    
    func loadLocalCurrentStoryPont(storyPointId: Int) {
        self.currentStoryPoints.removeAll()
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint != nil {
            self.currentStoryPoints.append(StoryPointManager.find(storyPointId))
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
        }
    }
    
    // MARK: - remote
    func loadRemoteAllStoryPonts(completion: ((success: Bool) -> ())!) {
        ApiClient.sharedClient.getAllStoryPoints({ (response) in
                StoryPointManager.saveStoryPoints(response as! [StoryPoint])
                completion(success: true)
            }, failure:  { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                completion(success: false)
            })
    }
    
    func loadRemoteStoryPont(storyPointId: Int, completion: ((success: Bool) -> ())!) {
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
