//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import AFImageHelper
import CoreLocation

class ContentViewController: ViewController, StoryPointCreationPopupDelegate, MenuDelegate {
    @IBOutlet weak var menuTabButton: UIButton!
    @IBOutlet weak var captureTabButton: UIButton!
    @IBOutlet weak var discoverTabButton: UIButton!
    @IBOutlet weak var profileTabButton: UIButton!
    @IBOutlet weak var parentView: UIView!
    
    var tabCaptureNavigationController: NavigationViewController! = nil
    var tabDiscoverNavigationController: NavigationViewController! = nil
    var pickedLocation: MCMapCoordinate! = nil
    
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
        (captureController as! CaptureViewController).addStoryPointButtonTapped = { [weak self] (location: MCMapCoordinate) -> () in
            self?.pickedLocation = location
            self?.routesShowPopupStoryPointCreationController(self!, location: location)
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
        self.captureTabButton.selected = false
        self.discoverTabButton.selected = false
        self.profileTabButton.selected = false
        button.selected = true
    }
    
    @IBAction func menuButtonDidTap(sender: AnyObject) {
        self.routerShowMenuController(self)
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
    
    // MARK: - private
    func openPhotoVideoController() {
        
        // TODO:
        
        self.routesOpenPhotoVideoViewController(self.pickedLocation)
    }
    
    // MARK: - storyPointCreationPopupDelegate
    func ambientDidTapped(location: MCMapCoordinate) {
        self.routesOpenAudioStoryPointController()
    }
    
    func photoVideoDidTapped(location: MCMapCoordinate) {
        self.openPhotoVideoController()
    }
    
    func textDidTapped(location: MCMapCoordinate) {
        self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Text, storyPointAttachmentId: "", location: location)
    }
    
    // MARK: - MenuDelegate
    func menuDidSelectItem(actionString:String) {
        self.performSelector(Selector(actionString))
    }
}