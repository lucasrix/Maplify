//
//  CaptureDataFetchingExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

extension CaptureViewController {
    
    // MARK: - database
    func loadLocalAllStoryPonts() {
        self.currentStoryPoints = StoryPointManager.allStoryPoints()
    }
    
    func loadLocalCurrentStoryPont(storyPointId: Int) {
        self.currentStoryPoints.removeAll()
        self.currentStoryPoints.append(StoryPointManager.find(storyPointId))
    }
    
    func loadLocalCurrentStory(storyId: Int) {
        self.currentStory = StoryManager.find(storyId)
        self.currentStoryPoints.removeAll()
        self.currentStoryPoints.appendContentsOf(Converter.listToArray(self.currentStory.storyPoints, type: StoryPoint.self))
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
