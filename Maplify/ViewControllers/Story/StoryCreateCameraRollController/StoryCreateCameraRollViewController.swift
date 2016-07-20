//
//  StoryCreateCameraRollViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

class StoryCreateCameraRollViewController: ViewController, CameraRollMultipleSelectionDelegate {
    var createStoryCompletion: createStoryClosure! = nil
    let cameraRollController = CameraRollMultipleSelectionController()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.populateViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBarItems()
    }
    
    deinit {
        PHCachingImageManager().stopCachingImagesForAllAssets()
    }
    
    // MARK: - setup
    func setup() {
        self.setupCameraRollController()
    }
    
    func setupNavigationBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(StoryCreateCameraRollViewController.cancelButtonTapped))
        self.addRightBarItem(NSLocalizedString("Button.Add", comment: String()))
    }
    
    func setupCameraRollController() {
        self.cameraRollController.delegate = self
        self.configureChildViewController(self.cameraRollController, onView: self.view)
    }
    
    func populateViews() {
        self.title = NSLocalizedString("Controller.CameraRoll.Title", comment: String())
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    func cancelButtonTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightBarButtonItemDidTap() {
        if self.cameraRollController.selectedAssets.count > 0 {
            let drafts = self.assetsToDrafts(self.cameraRollController.selectedAssets)
            self.routesOpenStoryCreateAddInfoController(drafts, createStoryCompletion: self.createStoryCompletion)
        }
    }
    
    private func assetsToDrafts(assets: [PHAsset]) -> [StoryPointDraft] {
        let options = AssetRetrievingManager.defaultImageOptions(false)
        PHCachingImageManager().startCachingImagesForAssets(assets, targetSize: Sizes.assetsTargetSizeDefault, contentMode: .AspectFill, options: options)
        var drafts = [StoryPointDraft]()
        for asset in assets {
            let storyPointDraft = StoryPointDraft()
            storyPointDraft.asset = asset
            storyPointDraft.coordinate = asset.location?.coordinate
            drafts.append(storyPointDraft)
        }
        return drafts
    }
    
    // MARK: - CameraRollMultipleSelectionDelegate
    func cameraRollUnauthorized() {
        self.showGalleryPermissionsError()
    }
    
    // MARK: - private
    private func showGalleryPermissionsError() {
        let title = NSLocalizedString("Alert.Gallery.Permissions.Title", comment: String()).capitalizedString
        let message = NSLocalizedString("Alert.Gallery.Permissions.Message", comment: String()).capitalizedString
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttonOpenSettingsTitle = NSLocalizedString("Button.OpenSettings", comment: String()).capitalizedString
        
        self.showAlert(title, message: message, cancel: cancel, buttons: [buttonOpenSettingsTitle]) { [weak self] (buttonIndex) in
            if buttonIndex == AlertButtonIndexes.Submit.rawValue {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            } else if buttonIndex == AlertButtonIndexes.Cancel.rawValue {
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}
