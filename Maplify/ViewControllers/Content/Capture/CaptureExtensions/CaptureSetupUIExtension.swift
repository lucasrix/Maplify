//
//  CaptureSetupUIExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import AMPopTip
import GoogleMaps
import CoreLocation

extension CaptureViewController {    
    func setupNavigationBar() {
        if self.contentType == .Story {
            self.setupDataDetailNavigationBar()
        } else if self.contentType == .StoryPoint {
           self.setupStoryCaptureNavigationBar()
        } else {
             self.setupDefaultCaptureNavigationBar()
        }
    }
    
    func setupBottomButtonIfNeeded() {
        if self.contentType == .Default {
            let cornerRadius = CGRectGetHeight(self.notificationsButton.frame) / 2
            
            let realm = try! Realm()
            let newNotificationsAvailable: Bool = realm.objects(Notification).filter("unread == true AND action_user != nil AND (notificable_user != nil OR notificable_storypoint != nil OR (notificable_story != nil AND notificable_story.storyPoints.@count > 0))").count > 0
            self.notificationsButton.layer.cornerRadius = cornerRadius
            self.notificationsButton.backgroundColor = newNotificationsAvailable == true ? UIColor.dodgerBlue() : UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationsButtonBackgroundColorAlpha)
            
            self.addStoryButton.layer.cornerRadius = cornerRadius
            self.addStoryButton.backgroundColor = UIColor.darkGreyBlue().colorWithAlphaComponent(kAddStoryButtonBackgroundColorAlpha)
            self.addStoryButton.setTitle(NSLocalizedString("Label.Story", comment: String()).uppercaseString, forState: .Normal)
            
            self.profileButton.layer.cornerRadius = cornerRadius
            self.profileButton.backgroundColor = UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationsButtonBackgroundColorAlpha)
        }
        self.notificationsButton.hidden = self.contentType != .Default
        self.addStoryButton.hidden = self.contentType != .Default
        self.profileButton.hidden = self.contentType != .Default
    }
    
    func setupDefaultCaptureNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoGps)!, target: self, action: #selector(CaptureViewController.gpsBarButtonHandler))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoSearch)!, target: self, action: #selector(CaptureViewController.searchBarButtonHandler))
    }
    
    func setupDataDetailNavigationBar() {
        if self.currentStory != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoMoreWhite)!, target: self, action: #selector(CaptureViewController.storyDetailMenuButtonTapped))
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(CaptureViewController.cancelButtonTapped))
    }
    
    func setupStoryCaptureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(CaptureViewController.cancelButtonTapped))
    }
    
    func setupPressAndHoldViewIfNeeded() {
        self.pressAndHoldView.layer.cornerRadius = CGRectGetHeight(self.pressAndHoldView.frame) / 2
        self.pressAndHoldLabel.text = NSLocalizedString("Label.PressAndHold", comment: String())
    }
    
    func setupTitle() {
        if self.contentType == .Story {
            self.title = self.currentStory?.title
        } else {
            self.setupDefaultTitle()
        }
    }
    
    func setupDefaultTitle() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    func setupPopTip() {
        let appearance = AMPopTip.appearance()
        appearance.popoverColor = UIColor.whiteColor().colorWithAlphaComponent(kPoptipPopoverColorAlpha)
        appearance.borderWidth = kPoptipBorderWidth
        appearance.rounded = true
    }
    
    func removePreviewItem() {
        if self.previewPlaceItem != nil {
            self.googleMapService.removeItem(self.previewPlaceItem)
            self.previewPlaceItem = nil
        }
        self.popTip?.hide()
    }
    
    func configuratePopup(locationInView: CGPoint, coordinate: MCMapCoordinate) {
        let popupView = CapturePopUpView(frame: CGRect(x: 0, y: 0, width: kPoptipViewWidth, height: kPoptipViewHeight))
        popupView.configure(coordinate) { [weak self] (locationString) in
            self?.locationString = locationString
        }
        
        self.popTip = AMPopTip()
        self.popTip.layer.shadowColor = UIColor.blackColor().CGColor
        self.popTip.layer.shadowOpacity = kPoptipShadowOpacity
        self.popTip.layer.shadowOffset = CGSizeZero
        self.popTip.layer.shadowRadius = kPoptipShadowRadius
        self.popTip.appearHandler = { [weak self] () -> () in self?.storyPointPopupCanCreate = true }
        self.popTip.tapHandler = { [weak self] () -> () in
            self?.routesOpenPhotoVideoViewController(coordinate, locationString: (self?.locationString)!, selectedStoryIds: [], creationPostCompletion: { (storyPointId) in
                self?.selectedStoryPointId = storyPointId
            })
        }
        self.popTip.showCustomView(popupView, direction: .Up, inView: self.view, fromFrame: CGRectMake(locationInView.x - kPinIconDeltaX, locationInView.y - kPinIconDeltaY, 0, 0))
        
        self.infiniteScrollView.hidden = true
        self.captureActiveModel.deselectAll()
        self.captureDataSource.reloadMapView(StoryPointMapItem)
    }
    
    // MARK: - actions
    func searchBarButtonHandler() {
        if self.placeSearchHelper.controllerVisible {
            self.placeSearchHelper.hideGooglePlaceSearchController()
        } else {
            self.placeSearchHelper.showGooglePlaceSearchController()
        }
    }
    
    func gpsBarButtonHandler() {
        if self.storyPointPopupCanCreate {
            self.storyPointPopupCanCreate = false
            self.retrieveCurrentLocation { (location) in
                if location != nil {
                    let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
                    let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let locationInView = (self.googleMapService.mapView as! GMSMapView).projection.pointForCoordinate(coordinate)
                    self.placePopUpPin(location.coordinate.latitude, longitude: location.coordinate.longitude, locationInView: locationInView)
                }
            }
        }
    }
    
    func storyDetailMenuButtonTapped() {
        self.showEditStoryContentMenu(self.selectedStoryId)
    }
    
    func cancelButtonTapped() {
        if self.poppingControllerSupport {
            self.popControllerFromLeft()
        } else {
            self.contentType = .Default
            self.selectedStoryPointId = 0
            self.infiniteScrollView.hidden = true
            self.loadData()
        }
    }
}

extension MCMapActiveModel {
    func find(storyPointId: Int) -> NSIndexPath {
        let indexPath = NSIndexPath(forItem: NSNotFound, inSection: NSNotFound)
        var row = 0
        var section = 0
        
        for dataArray in self.sectionsArray! {
            for cellData in dataArray {
                if (cellData.model is StoryPoint) {
                    if (cellData.model as! StoryPoint).id == storyPointId {
                        return NSIndexPath(forRow: row, inSection: section)
                    }
                }
                row += 1
            }
            section += 1
        }
        return indexPath
    }
}