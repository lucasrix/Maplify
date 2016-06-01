//
//  CaptureDetailViewExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import CoreLocation

extension CaptureViewController: InfiniteScrollViewDelegate, StoryPointInfoViewDelegate, StoryInfoViewDelegate {
    func setupInfiniteScrollView() {
        self.infiniteScrollView.pageControlDelegate = self
        self.infiniteScrollView.cellModeEnabled = true
        self.infiniteScrollView.yViewsOffset = kDetailViewYOffset
        self.infiniteScrollView.cellCornerRadius = CornerRadius.detailViewBorderRadius
    }
    
    // MARK: - InfiniteScrollViewDelegate
    func didShowPageView(pageControl: InfiniteScrollView, view: UIView, index: Int) {
        let model = self.captureActiveModel.cellData(NSIndexPath(forRow: index, inSection: 0)).model as! Model
        if model is StoryPoint {
            DetailMapItemHelper.configureStoryPointView(view, storyPoint: model as! StoryPoint, delegate: self)
        } else if model is Story {
            DetailMapItemHelper.configureStoryView(view, story: model as! Story, delegate: self)
        }
    }
    
    func didScrollPageView(pageControl: InfiniteScrollView, index: Int) {
        self.captureActiveModel.selectPinAtIndex(index)
        self.captureDataSource.reloadMapView(StoryPointMapItem)
        if index < self.captureActiveModel.numberOfItems(0) {
            let model = self.captureActiveModel.cellData(NSIndexPath(forRow: index, inSection: 0)).model
            if model is StoryPoint {
                let location = CLLocationCoordinate2DMake((model as! StoryPoint).location.latitude , (model as! StoryPoint).location.longitude)
                let pointInView = self.googleMapService.pointFromLocation(location)
                self.scrollToDestinationPointWithOffset(pointInView)
            }
        }
    }
    
    func scrollToDestinationPointWithOffset(pointInView: CGPoint) {
        let x = self.mapView.center.x + kPinWidthOffset
        let y = (NavigationBar.defaultHeight + self.infiniteScrollViewTopConstraint.constant / 2 + kPinHeightOffset)
        self.googleMapService.scrollMapToPoint(pointInView, destinationPoint: CGPointMake(x, y))
    }
    
    func numberOfItems() -> Int {
        return self.captureActiveModel.numberOfItems(0)
    }
    
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
        self.contentType = .Story
        self.selectedStoryId = storyId
        self.updateData()
    }
    
    func updateInfiniteScrollIfNeeded() {
        if self.contentType == .Story {
            self.infiniteScrollView.moveAndShowCell(0, animated: false)
        }
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
                                                            StoryPointManager.saveStoryPoint(response as! StoryPoint)
                                                            StoryPointManager.delete(storyPoint)
                                                            self?.infiniteScrollView.deleteCurrentView()
                                                            self?.hideProgressHUD()
                                                            self?.loadData()
                    },
                                                        failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                            self?.hideProgressHUD()
                                                            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                    }
                )
            }
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
                                                    let story = StoryManager.find(storyId)
                                                    StoryLinkManager.deleteStoryLink(storyId)
                                                    StoryManager.delete(story)
                                                    self?.infiniteScrollView.deleteCurrentView()
                                                    self?.hideProgressHUD()
                                                    self?.cancelButtonTapped()
                    },
                                                   failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                    self?.hideProgressHUD()
                                                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                    })
            }
        }
    }
    
    func reportStoryPoint(storyPointId: Int) {
        self.routesOpenReportsController(storyPointId, postType: .StoryPoint) {
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    func shareStoryPoint(storyPointId: Int) {
        self.routesOpenShareStoryPointViewController(storyPointId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
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
}
