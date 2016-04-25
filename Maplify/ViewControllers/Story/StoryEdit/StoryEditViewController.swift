//
//  StoryEditViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryEditViewController: ViewController, UITextViewDelegate {
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
        
        self.populateViews()
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
        self.setupStoryNameViews()
        self.setupStoryDescriptionViews()
        self.setupStoryPointsView()
    }
    
    func setupStoryNameViews() {
        self.storyNameLabel.text = NSLocalizedString("Label.StoryName", comment: String())
        self.storyNameTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterBriefTitle", comment: String())
    }
    
    func setupStoryDescriptionViews() {
        self.descriptionLabel.text = NSLocalizedString("Label.Description", comment: String())
        self.updateCharactersCountLabel((self.descriptionTextView.text?.length)!)
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.layer.cornerRadius = CornerRadius.defaultRadius
        self.descriptionTextView.clipsToBounds = true
        self.descriptionTextView.layer.borderWidth = kAboutFieldBorderWidth
        self.descriptionTextView.layer.borderColor = UIColor.inactiveGrey().CGColor
    }
    
    func setupStoryPointsView() {
        self.pointsInStoryLabel.text = NSLocalizedString("Label.PostsInThisStory", comment: String())
        self.addPostsButton.setTitle(NSLocalizedString("Button.AddPosts", comment: String()).uppercaseString, forState: .Normal)
    }
    
    func populateViews() {
        let story = StoryManager.find(self.storyId)
        self.storyNameTextField.text = story.title
        self.descriptionTextView.text = story.storyDescription
    }

    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let resultCharactersCount = (self.descriptionTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text).length
        if resultCharactersCount <= kDescriptionTextViewMaxCharactersCount {
            self.updateCharactersCountLabel(resultCharactersCount)
            return true
        }
        return false
    }
    
    func updateCharactersCountLabel(charactersCount: Int) {
        let substringOf = NSLocalizedString("Substring.Of", comment: String())
        let substringChars = NSLocalizedString("Substring.Chars", comment: String())
        self.descriptionCharsNumberLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
    }
}
