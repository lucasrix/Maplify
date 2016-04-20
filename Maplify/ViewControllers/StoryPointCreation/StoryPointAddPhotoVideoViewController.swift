//
//  StoryPointAddPhotoVideoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 3/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Haneke
import UIKit

let kVideoDurationSecondsMax: Double = 20

class StoryPointAddPhotoVideoViewController: ViewController, CameraRollDelegate, PhotoControllerDelegate, VideoControllerDelagate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    var pickedLocation: MCMapCoordinate! = nil
    var currentChildController: UIViewController! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupBottomButtons()
        self.setupAppearState()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
    }
    
    func setupBottomButtons() {
        self.setupButton(self.galleryButton, imageNameHighlited: MediaButtons.galleryHighlited)
        self.setupButton(self.photoButton, imageNameHighlited: MediaButtons.photoHighlited)
        self.setupButton(self.videoButton, imageNameHighlited: MediaButtons.videoHighlited)
    }
    
    func setupButton(button: UIButton, imageNameHighlited: String) {
        button.setBackgroundImage(UIImage(color: UIColor.darkBlueGrey()), forState: .Normal)
        button.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Highlighted)
        button.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Selected)
        button.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: [.Highlighted, .Selected])
        button.setTitleColor(UIColor.whiteColor(), forState: [.Highlighted, .Selected])
        button.setImage(UIImage(named: imageNameHighlited), forState: [.Highlighted, .Selected])
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - navigation bar item actions
    override func rightBarButtonItemDidTap() {
        if self.currentChildController is CameraRollViewController {
            (self.currentChildController as! CameraRollViewController).donePressed()
        } else if self.currentChildController is PhotoViewController {
            (self.currentChildController as! PhotoViewController).donePressed()
        } else if self.currentChildController is VideoViewController {
            (self.currentChildController as! VideoViewController).donePressed()
        }
    }
    
    // MARK: - actions
    @IBAction func galleryTapped(sender: UIButton) {
        self.updateControllerTitle(NSLocalizedString("Controller.CameraRoll.Title", comment: String()))
        self.selectButton(sender)
        let cameraRollController = CameraRollViewController()
        cameraRollController.delegate = self
        self.showController(cameraRollController)
    }
    
    @IBAction func photoTapped(sender: UIButton) {
        self.updateControllerTitle(NSLocalizedString("Controller.Photo.Title", comment: String()))
        self.selectButton(sender)
        let photoController = PhotoViewController()
        photoController.delegate = self
        self.showController(photoController)
    }
    
    @IBAction func videoTapped(sender: UIButton) {
        self.updateControllerTitle(NSLocalizedString("Controller.Video.Title", comment: String()))
        self.selectButton(sender)
        let videoViewController = VideoViewController()
        videoViewController.delegate = self
        self.showController(videoViewController)
    }
    
    // MARK: - remote
    func remotePostAttachment(storyPointKind: StoryPointKind, fileData: NSData) {
        self.showProgressHUD()
        var params: [String: AnyObject]! = nil
        if storyPointKind == StoryPointKind.Photo {
                params = ["mimeType": "image/png", "fileName": "photo.png"]
        } else if storyPointKind == StoryPointKind.Video {
            params = ["mimeType": "video/quicktime", "fileName": "video.mov"]
        }
        
        ApiClient.sharedClient.postAttachment(fileData, params: params, success: { [weak self] (response) -> () in
            
            self?.hideProgressHUD()
            let attachmentID = (response as! Attachment).id
            self?.routesOpenStoryPointEditDescriptionController(storyPointKind, storyPointAttachmentId: attachmentID, location: (self?.pickedLocation)!)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
            
            self?.hideProgressHUD()
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - private
    private func setupAppearState() {
        self.galleryTapped(self.galleryButton)
    }
    
    private func updateControllerTitle(title: String) {
        self.title = title
    }
    
    private func selectButton(button: UIButton) {
        self.galleryButton.selected = false
        self.photoButton.selected = false
        self.videoButton.selected = false
        button.selected = true
    }
    
    private func showController(controller: UIViewController) {
        if let childController = self.currentChildController {
            self.removeChildController(childController)
        }
        self.currentChildController = controller
        self.configureChildViewController(controller, onView: self.containerView)
    }
    
    private func showGalleryPermissionsError() {
        let title = NSLocalizedString("Alert.Gallery.Permissions.Title", comment: String()).capitalizedString
        let message = NSLocalizedString("Alert.Gallery.Permissions.Message", comment: String()).capitalizedString
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttonOpenSettingsTitle = NSLocalizedString("Button.OpenSettings", comment: String()).capitalizedString
        
        self.showAlert(title, message: message, cancel: cancel, buttons: [buttonOpenSettingsTitle]) { [weak self] (buttonIndex) in
            if buttonIndex == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                self?.navigationController?.popViewControllerAnimated(true)
            } else if buttonIndex == 1 {
                self?.photoTapped(self!.photoButton)
            }
        }
    }
    
    private func showCameraPermissionsError() {
        let title = NSLocalizedString("Alert.Camera.Permissions.Title", comment: String()).capitalizedString
        let message = NSLocalizedString("Alert.Camera.Permissions.Message", comment: String()).capitalizedString
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttonOpenSettingsTitle = NSLocalizedString("Button.OpenSettings", comment: String()).capitalizedString
        
        self.showAlert(title, message: message, cancel: cancel, buttons: [buttonOpenSettingsTitle]) { [weak self] (buttonIndex) in
            if buttonIndex == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            }
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - CameraRollDelegate
    func imageDidSelect(imageData: NSData) {
        self.remotePostAttachment(StoryPointKind.Photo, fileData: imageData)
    }
    
    func cameraRollUnauthorized() {
        self.showGalleryPermissionsError()
    }
    
    func videoDidSelect(videoData: NSData, duration: Double) {
        if duration < kVideoDurationSecondsMax {
            self.remotePostAttachment(StoryPointKind.Video, fileData: videoData)
        } else {
            self.showVideoDurationError()
        }
    }
    
    func showVideoDurationError() {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        let message = NSLocalizedString("Label.VideoDurationError", comment: String())
        self.showMessageAlert(title, message: message, cancel: cancel)
    }
    
    // MARK: - PhotoControllerDelegate
    func photoDidTake(imageData: NSData) {
        self.remotePostAttachment(StoryPointKind.Photo, fileData: imageData)
    }
    
    func photoCameraUnauthorized() {
        self.showCameraPermissionsError()
    }
    
    // MARK: - VideoControllerDelagate
    func videoDidWrite(videoData: NSData) {
        self.remotePostAttachment(StoryPointKind.Video, fileData: videoData)
    }
    
    func videoCameraUnauthorized() {
        self.showCameraPermissionsError()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
