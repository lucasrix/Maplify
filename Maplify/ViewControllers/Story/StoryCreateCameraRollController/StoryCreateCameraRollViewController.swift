//
//  StoryCreateCameraRollViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryCreateCameraRollViewController: ViewController {
    var createStoryCompletion: createStoryClosure! = nil

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupCameraRollController()
    }
    
    func setupCameraRollController() {
        let cameraRollController = CameraRollMultipleSelectionController()
        self.configureChildViewController(cameraRollController, onView: self.view)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
}
