//
//  CaptureStoryPointInfoViewExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

extension CaptureViewController {
    
    // MARK: - StoryPointInfoViewDelegate
    func profileImageTapped(userId: Int) {
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
    func likeStoryPointDidTap(storyPointId: Int, completion: ((success: Bool) -> ())) {
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint.liked {
            self.unlikeStoryPoint(storyPointId, completion: completion)
        } else {
            self.likeStoryPoint(storyPointId, completion: completion)
        }
    }
    
    private func likeStoryPoint(storyPointId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.likeStoryPoint(storyPointId, success: { (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            completion(success: true)
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    private func unlikeStoryPoint(storyPointId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.unlikeStoryPoint(storyPointId, success: { (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            completion(success: true)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    func shareStoryPointDidTap(storyPointId: Int) {
        self.routesOpenShareStoryPointViewController(storyPointId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    func didSelectStory(storyId: Int) {
        ApiClient.sharedClient.getStory(storyId, success: { [weak self] (response) in
            self?.mapActiveModel.removeData()
            self?.storyPointActiveModel.removeData()
            self?.contentType = .Story
            self?.storyToShow = response as! Story
            self?.setupDataDetailNavigationBar((self?.storyToShow)!)
            
            StoryManager.saveStory((self?.storyToShow)!)
            
            self?.mapDataSource.reloadMapView(StoryPointMapItem)
            self?.storyPointActiveModel.addItems(Array((self?.storyToShow.storyPoints)!), cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
            self?.mapActiveModel.addItems(Array((self?.storyToShow.storyPoints)!))
            self?.infiniteScrollView.moveAndShowCell(0, animated: false)
            }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
    }
    
    func storyPointMenuButtonTapped(storyPointId: Int) {
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint.user.profile.id == SessionManager.currentUser().profile.id {
            
            self.showStoryPointEditContentActionSheet( { [weak self] (selectedIndex) -> () in
                if selectedIndex == StoryPointEditContentOption.EditPost.rawValue {
                    self?.routesOpenStoryPointEditController(storyPointId, storyPointUpdateHandler: nil)
                } else if selectedIndex == StoryPointEditContentOption.DeletePost.rawValue {
                    self?.deleteStoryPoint(storyPointId)
                } else if selectedIndex == StoryPointEditContentOption.SharePost.rawValue {
                    self?.shareStoryPoint(storyPointId)
                }
                })
        } else {
            self.showStoryPointDefaultContentActionSheet( { [weak self] (selectedIndex) in
                if selectedIndex == StoryPointDefaultContentOption.SharePost.rawValue {
                    self?.shareStoryPoint(storyPointId)
                } else if selectedIndex == StoryPointDefaultContentOption.ReportAbuse.rawValue {
                    self?.reportStoryPoint(storyPointId)
                }
                })
        }
    }
    
    func shareStoryPoint(storyPointId: Int) {
        self.routesOpenShareStoryPointViewController(storyPointId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    func deleteStoryPoint(storyPointId: Int) {
        let storyPoint = StoryPointManager.find(storyPointId)
        let alertMessage = NSLocalizedString("Alert.DeleteStoryPoint", comment: String())
        let yesButton = NSLocalizedString("Button.Yes", comment: String())
        let noButton = NSLocalizedString("Button.No", comment: String())
        self.showAlert(nil, message: alertMessage, cancel: yesButton, buttons: [noButton]) { (buttonIndex) in
            if buttonIndex != 0 {
                self.showProgressHUD()
                ApiClient.sharedClient.deleteStoryPoint(storyPointId,
                                                        success: { [weak self] (response) in
                                                            self?.hideProgressHUD()
                                                            StoryPointManager.delete(storyPoint)
                                                            self?.infiniteScrollView.deleteCurrentView()
                                                            self?.loadItemsFromDBIfNedded()
                    },
                                                        failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                            self?.hideProgressHUD()
                                                            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                    }
                )
            }
        }
    }
    
    func reportStoryPoint(storyPointId: Int) {
        self.routesOpenReportsController(storyPointId, postType: .StoryPoint) {
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
}
