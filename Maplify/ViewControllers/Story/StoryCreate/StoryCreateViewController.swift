//
//  StoryCreateViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryCreateViewController: ViewController, UITextViewDelegate {
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    deinit {
        self.unsubscribeNotifications()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.subscribeNotifications()
        self.setupStoryNameViews()
        self.setupStoryDescriptionViews()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.NewStory", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
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
        self.descriptionTextView.layer.borderWidth = Border.defaultBorderWidth
        self.descriptionTextView.layer.borderColor = UIColor.inactiveGrey().CGColor
    }
    
    // MARK: - notifications/observers
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoryCreateViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        if self.storyNameTextField.text != String() {
            self.routesOpenStoryAddPostsViewController(0, delegate: nil, storyModeCreation: true, storyName: self.storyNameTextField.text!, storyDescription: self.descriptionTextView.text)
        }
    }
    
    // MARK: - keyboard notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animateWithDuration(duration, animations: { [weak self] () -> Void in
            self!.bottomConstraint.constant = keyboardFrame.size.height
            self!.view.layoutIfNeeded()
            })
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
        self.charactersCountLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
    }
}
