//
//  CaptureStoryInfoViewExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

extension CaptureViewController {
    
    // MARK: - StoryInfoViewDelegate
    func storyProfileImageTapped(userId: Int) {
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
    func likeStoryDidTap(storyId: Int, completion: ((success: Bool) -> ())) {
        let story = StoryManager.find(storyId)
        if story.liked {
            self.unlikeStory(storyId, completion: completion)
        } else {
            self.likeStory(storyId, completion: completion)
        }
    }
    
    func shareStoryDidTap(storyId: Int) {
        self.routesOpenShareStoryViewController(storyId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    private func likeStory(storyId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.likeStory(storyId, success: { (response) in
            StoryManager.saveStory(response as! Story)
            completion(success: true)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    private func unlikeStory(storyId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.unlikeStory(storyId, success: { (response) in
            StoryManager.saveStory(response as! Story)
            completion(success: true)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    func showEditStoryContentMenu(storyId: Int) {
        let story = StoryManager.find(storyId)
        if story.user.profile.id == SessionManager.currentUser().profile.id {
            self.showEditStoryContentActionSheet({ [weak self] (selectedIndex) in
                if selectedIndex == StoryEditContentOption.EditStory.rawValue {
                    self?.routesOpenStoryEditController(storyId, storyUpdateHandler: nil)
                } else if selectedIndex == StoryEditContentOption.DeleteStory.rawValue {
                    self?.deleteStory(storyId)
                } else if selectedIndex == StoryEditContentOption.ShareStory.rawValue {
                    self?.shareStory(storyId)
                }
                })
        } else {
            self.showStoryDefaultContentActionSheet( { [weak self] (selectedIndex) in
                if selectedIndex == StoryDefaultContentOption.ShareStory.rawValue {
                    self?.shareStory(storyId)
                } else if selectedIndex == StoryDefaultContentOption.ReportAbuse.rawValue {
                    self?.reportStory(storyId)
                }
                })
        }
    }
    
    func shareStory(storyId: Int) {
        self.routesOpenShareStoryViewController(storyId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    func reportStory(storyId: Int) {
        self.routesOpenReportsController(storyId, postType: .Story) {
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    func deleteStory(storyId: Int) {
        let alertMessage = NSLocalizedString("Alert.DeleteStoryPoint", comment: String())
        let yesButton = NSLocalizedString("Button.Yes", comment: String())
        let noButton = NSLocalizedString("Button.No", comment: String())
        self.showAlert(nil, message: alertMessage, cancel: yesButton, buttons: [noButton]) { (buttonIndex) in
            if buttonIndex != 0 {
                self.showProgressHUD()
                ApiClient.sharedClient.deleteStory(storyId,
                                                   success: { [weak self] (response) in
                                                    StoryManager.saveStory(response as! Story)
                                                    let discoverItem = DiscoverItemManager.findWithStory(storyId)
                                                    let story = StoryManager.find(storyId)
                                                    if (story != nil) && (discoverItem != nil) {
                                                        DiscoverItemManager.delete(discoverItem)
                                                        StoryManager.delete(story)
                                                    }
                                                    self?.hideProgressHUD()
                                                    self?.loadItemsFromDBIfNedded()
                    },
                                                   failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                    self?.hideProgressHUD()
                                                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                    })
            }
        }
    }
}
