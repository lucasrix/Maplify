//
//  AddStoryViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class AddStoryViewController: ViewController {
    @IBOutlet weak var myStoriesLabel: UILabel!
    @IBOutlet weak var createStoryButton: UIButton!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.AddToStory.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Add", comment: String()))
        self.myStoriesLabel.text = NSLocalizedString("Label.MyStories", comment: String().uppercaseString)
        self.createStoryButton.setTitle(NSLocalizedString("Button.CreateStory", comment: String().uppercaseString), forState: .Normal)
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
        // TODO:
    }
}
