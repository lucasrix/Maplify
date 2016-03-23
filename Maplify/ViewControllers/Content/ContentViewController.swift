//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Fusuma
import Haneke
import AFImageHelper

class ContentViewController: ViewController, StoryPointCreationPopupDelegate, FusumaDelegate {
    @IBOutlet weak var menuTabButton: UIButton!
    @IBOutlet weak var captureTabButton: UIButton!
    @IBOutlet weak var discoverTabButton: UIButton!
    @IBOutlet weak var profileTabButton: UIButton!
    @IBOutlet weak var parentView: UIView!
    
    var tabCaptureNavigationController: NavigationViewController! = nil
    var tabDiscoverNavigationController: NavigationViewController! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupTabButtons()
        self.setupControllers()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupControllers() {        
        let captureController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController)
        (captureController as! CaptureViewController).addStoryPointButtonTapped = { [weak self] () -> () in
            self?.routesShowPopupStoryPointCreationController(self!)
        }
        self.tabCaptureNavigationController = NavigationViewController(rootViewController: captureController)
        self.tabCaptureNavigationController.navigationBar.barStyle = .Black
        
        let discoverController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.discoverController)
        self.tabDiscoverNavigationController = NavigationViewController(rootViewController: discoverController)

        self.replaceChildViewController(self.tabCaptureNavigationController, parentView: self.parentView)
        self.captureTabButton.selected = true
    }
    
    func setupTabButtons() {
        self.menuTabButton.setBackgroundImage(UIImage(color: UIColor.darkBlueGrey()), forState: .Normal)
        self.menuTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Highlighted)
        self.menuTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Selected)
        self.menuTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: [.Highlighted, .Selected])
        self.menuTabButton.setTitleColor(UIColor.whiteColor(), forState: [.Highlighted, .Selected])
        self.menuTabButton.setImage(UIImage(named: TabButtonImages.menuHighlighted), forState: [.Highlighted, .Selected])
        
        self.captureTabButton.setBackgroundImage(UIImage(color: UIColor.darkBlueGrey()), forState: .Normal)
        self.captureTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Highlighted)
        self.captureTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Selected)
        self.captureTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: [.Highlighted, .Selected])
        self.captureTabButton.setTitleColor(UIColor.whiteColor(), forState: [.Highlighted, .Selected])
        self.captureTabButton.setImage(UIImage(named: TabButtonImages.locationHighlighted), forState: [.Highlighted, .Selected])
        
        self.discoverTabButton.setBackgroundImage(UIImage(color: UIColor.darkBlueGrey()), forState: .Normal)
        self.discoverTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Highlighted)
        self.discoverTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Selected)
        self.discoverTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: [.Highlighted, .Selected])
        self.discoverTabButton.setTitleColor(UIColor.whiteColor(), forState: [.Highlighted, .Selected])
        self.discoverTabButton.setImage(UIImage(named: TabButtonImages.discoverHighlighted), forState: [.Highlighted, .Selected])
        
        self.profileTabButton.setBackgroundImage(UIImage(color: UIColor.darkBlueGrey()), forState: .Normal)
        self.profileTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Highlighted)
        self.profileTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: .Selected)
        self.profileTabButton.setBackgroundImage(UIImage(color: UIColor.darkGreyBlue()), forState: [.Highlighted, .Selected])
        self.profileTabButton.setTitleColor(UIColor.whiteColor(), forState: [.Highlighted, .Selected])
        self.profileTabButton.setImage(UIImage(named: TabButtonImages.profileHighlighted), forState: [.Highlighted, .Selected])
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }

    // MARK: - actions
    func selectTabButton(button: UIButton) {
        self.menuTabButton.selected = false
        self.captureTabButton.selected = false
        self.discoverTabButton.selected = false
        self.profileTabButton.selected = false
        button.selected = true
    }
    
    @IBAction func menuButtonDidTap(sender: AnyObject) {
        self.selectTabButton(sender as! UIButton)
    }
    
    @IBAction func captureButtonDidTap(sender: AnyObject) {
        self.selectTabButton(sender as! UIButton)
        self.replaceChildViewController(self.tabCaptureNavigationController, parentView: self.parentView)
    }
    
    @IBAction func discoverButtonDidTap(sender: AnyObject) {
        self.selectTabButton(sender as! UIButton)
        self.replaceChildViewController(self.tabDiscoverNavigationController, parentView: self.parentView)
    }
    
    @IBAction func profileButtonDidTap(sender: AnyObject) {
        self.selectTabButton(sender as! UIButton)
    }
    
    @IBAction func createStoryPointTapped(sender: UIButton) {
        self.routesShowPopupStoryPointCreationController(self)
    }
    
    // MARK: - private
    func openFusumaController() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    // MARK: - storyPointCreationPopupDelegate
    func ambientDidTapped() {
    // TODO:
    }
    
    func photoVideoDidTapped() {
//        self.routesOpenStoryPointAddPhotoVideoController()
        self.openFusumaController()
    }
    
    func textDidTapped() {
        self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Text, storyPointAttachmentId: "")
    }
    
    // MARK: - FusumaDelegate
    func fusumaImageSelected(image: UIImage) {
        
        // cashing image
        let cache = Shared.imageCache
        let uniqeId = NSUUID().UUIDString
        cache.set(value: image, key: uniqeId)
        self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Photo, storyPointAttachmentId: uniqeId)
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        // TODO:
        print("Camera roll unauthorized")
    }
    
    // (Optional) Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        // TODO:
        print("Called just after FusumaViewController is dismissed.")
    }
}