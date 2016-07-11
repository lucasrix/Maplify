//
//  StoryCreateAddInfoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

class StoryCreateAddInfoViewController: ViewController {
    
    var createStoryCompletion: createStoryClosure! = nil
    var selectedAssets = [PHAsset]()

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBarItems()
    }
    
    // MARK: - setup
    func setup() {
        
    }
    
    func setupNavigationBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(StoryCreateAddInfoViewController.cancelButtonTapped))
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
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
        // TODO:
    }
}
