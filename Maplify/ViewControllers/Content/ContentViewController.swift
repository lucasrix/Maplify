//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import AFImageHelper
import CoreLocation

class ContentViewController: ViewController, StoryPointCreationPopupDelegate {
    @IBOutlet weak var parentView: UIView!
    
    var tabCaptureNavigationController: NavigationViewController! = nil
    var tabDiscoverNavigationController: NavigationViewController! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    // MARK: - setup
    func setup() {
        self.setupControllers()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupControllers() {        
        let captureController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController) as! CaptureViewController
        captureController.addStoryPointButtonTapped = { [weak self] (location: MCMapCoordinate, locationString: String) -> () in
            self?.routesOpenAddToStoryController([], storypointCreationSupport: true, pickedLocation: location, locationString: locationString, updateStoryHandle: nil, creationPostCompletion: nil)
        }
        self.tabCaptureNavigationController = NavigationViewController(rootViewController: captureController)
        self.tabCaptureNavigationController.navigationBar.barStyle = .Black

        self.replaceChildViewController(self.tabCaptureNavigationController, parentView: self.parentView)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - storyPointCreationPopupDelegate
    func ambientDidTapped(location: MCMapCoordinate) {
        self.routesOpenAudioStoryPointController(location)
    }
    
    func photoVideoDidTapped(location: MCMapCoordinate) {
        self.routesOpenAddToStoryController([], storypointCreationSupport: true, pickedLocation: location, locationString: String(), updateStoryHandle: nil, creationPostCompletion: nil)
    }
    
    func textDidTapped(location: MCMapCoordinate) {
        self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Text, storyPointAttachmentId: 0, location: location, selectedStoryIds: nil, locationString: String(), creationPostCompletion: nil)
    }
}