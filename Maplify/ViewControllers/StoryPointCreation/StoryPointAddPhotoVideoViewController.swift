//
//  StoryPointAddPhotoVideoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 3/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Haneke
import UIKit

class StoryPointAddPhotoVideoViewController: ViewController, CameraRollDelegate {
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
        (self.currentChildController as! CameraRollViewController).donePressed()
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
    }
    
    @IBAction func videoTapped(sender: UIButton) {
        self.updateControllerTitle(NSLocalizedString("Controller.Video.Title", comment: String()))
        self.selectButton(sender)
        
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
    
    // MARK: - CameraRollDelegate
    func imageDidSelect(image: UIImage) {
        let cache = Shared.imageCache
        let uniqeId = NSUUID().UUIDString
        cache.set(value: image, key: uniqeId)
        self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Photo, storyPointAttachmentId: uniqeId, location: self.pickedLocation)
    }
    
    func cameraRollUnauthorized() {
        print("unauth")
    }
}
