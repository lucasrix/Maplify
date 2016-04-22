//
//  StoryEditViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryEditViewController: ViewController {
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionCharsNumberLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var pointsInStoryLabel: UILabel!
    @IBOutlet weak var addPostsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var storyId: Int = 0
    var storyUpdateHandler: (() -> ())! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupContent()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupViews()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.EditStory", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
    }
    
    func setupViews() {
        self.descriptionTextView.layer.cornerRadius = CornerRadius.defaultRadius
        self.descriptionTextView.clipsToBounds = true
        self.descriptionTextView.layer.borderWidth = kAboutFieldBorderWidth
        self.descriptionTextView.layer.borderColor = UIColor.inactiveGrey().CGColor
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
}
