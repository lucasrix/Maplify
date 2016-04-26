//
//  StoryAddPostsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryAddPostsViewController: ViewController {
    var storyId: Int = 0
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.AddPosts", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - navigation bar actions
    override func rightBarButtonItemDidTap() {
        // TODO:
    }
}
