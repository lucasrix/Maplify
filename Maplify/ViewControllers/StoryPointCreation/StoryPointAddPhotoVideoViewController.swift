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

class StoryPointAddPhotoVideoViewController: ViewController, CameraRollDelegate, PhotoControllerDelegate, VideoControllerDelagate, AmbientControllerDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    var pickedLocation: MCMapCoordinate! = nil
    var currentChildController: UIViewController! = nil
    var selectedStoryIds: [Int]! = nil
    
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
        self.setupButton(self.micButton, imageNameHighlited: MediaButtons.micHighlited)
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
        } else if self.currentChildController is AmbientViewController {
            (self.currentChildController as! AmbientViewController).donePressed()
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
    
    @IBAction func micTapped(sender: UIButton) {
        self.updateControllerTitle(NSLocalizedString("Controller.Ambient.Title", comment: String()))
        self.selectButton(sender)
        let ambientViewController = AmbientViewController()
        ambientViewController.delegate = self
        self.showController(ambientViewController)
    }
    
    // MARK: - remote
    func remotePostAttachment(storyPointKind: StoryPointKind, fileData: NSData) {
        self.showProgressHUD()
        var params: [String: AnyObject]! = nil
        if storyPointKind == .Photo {
                params = ["mimeType": "image/png", "fileName": "photo.png"]
        } else if storyPointKind == .Video {
            params = ["mimeType": "video/quicktime", "fileName": "video.mov"]
        } else if storyPointKind == .Audio {
            params = ["mimeType": "audio/m4a", "fileName": "audio.m4a"]
        }
        
        ApiClient.sharedClient.postAttachment(fileData, params: params, success: { [weak self] (response) -> () in
            
            self?.hideProgressHUD()
            let attachmentID = (response as! Attachment).id
            self?.routesOpenStoryPointEditDescriptionController(storyPointKind, storyPointAttachmentId: attachmentID, location: (self?.pickedLocation)!, selectedStoryIds: self?.selectedStoryIds)
            
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
        self.micButton.selected = false
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
    
    private func showAudioPermissionsError() {
        let title = NSLocalizedString("Alert.Audio.Permissions.Title", comment: String()).capitalizedString
        let message = NSLocalizedString("Alert.Audio.Permissions.Message", comment: String()).capitalizedString
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttonOpenSettingsTitle = NSLocalizedString("Button.OpenSettings", comment: String()).capitalizedString
        
        self.showAlert(title, message: message, cancel: cancel, buttons: [buttonOpenSettingsTitle]) { [weak self] (buttonIndex) in
            if buttonIndex == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            }
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func postTextStoryPoint() {
        self.routesOpenStoryPointEditDescriptionController(.Text, storyPointAttachmentId: 0, location: (self.pickedLocation)!, selectedStoryIds: self.selectedStoryIds)
    }
    
    // MARK: - CameraRollDelegate
    func imageDidSelect(imageData: NSData!) {
        if imageData != nil {
            self.remotePostAttachment(StoryPointKind.Photo, fileData: imageData)
        } else {
            self.postTextStoryPoint()
        }
    }
    
    func cameraRollUnauthorized() {
        self.showGalleryPermissionsError()
    }
    
    func videoDidSelect(videoData: NSData!, duration: Double) {
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
    func photoDidTake(imageData: NSData!) {
        if imageData != nil {
            self.remotePostAttachment(.Photo, fileData: imageData)
        } else {
            self.postTextStoryPoint()
        }
    }
    
    func photoCameraUnauthorized() {
        self.showCameraPermissionsError()
    }
    
    // MARK: - VideoControllerDelagate
    func videoDidWrite(videoData: NSData!) {
        if videoData != nil {
            self.remotePostAttachment(.Video, fileData: videoData)
        } else {
            self.postTextStoryPoint()
        }
    }
    
    func videoCameraUnauthorized() {
        self.showCameraPermissionsError()
    }
    
    // MARK: - AmbientControllerDelegate
    func audioDidRecord(audioData: NSData!) {
        if audioData != nil {
            self.remotePostAttachment(.Audio, fileData: audioData)
        } else {
            self.postTextStoryPoint()
        }
    }
    
    func audioMicrophoneUnauthorized() {
        self.showAudioPermissionsError()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
