//
//  StoryCreateViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kMaxStoryNameLength: Int = 25

class StoryCreateViewController: ViewController, UITextViewDelegate {
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var createStoryCompletion: createStoryClosure! = nil
        
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
        if self.storyNameTextField.text?.length > kMaxStoryNameLength {
            let message = NSLocalizedString("Alert.StoryNameTooLong", comment: String())
            let title = NSLocalizedString("Alert.Error", comment: String())
            let cancel = NSLocalizedString("Button.Ok", comment: String())
            self.showMessageAlert(title, message: message, cancel: cancel)
        } else if (self.storyNameTextField.text?.length > 0) && (self.storyNameTextField.text?.isNonWhiteSpace)! {
            self.routesOpenStoryAddPostsViewController(nil, delegate: nil, storyModeCreation: true, storyName: self.storyNameTextField.text!, storyDescription: self.descriptionTextView.text, createStoryCompletion: self.createStoryCompletion)
        } else {
            let message = NSLocalizedString("Error.EmptyStoryName", comment: String())
            let title = NSLocalizedString("Alert.Error", comment: String())
            let cancel = NSLocalizedString("Button.Ok", comment: String())
            self.showMessageAlert(title, message: message, cancel: cancel)
        }
    }
    
    // MARK: - keyboard notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        UIView.animateWithDuration(duration, animations: { [weak self] () -> () in
            self?.bottomConstraint.constant = keyboardFrame.size.height
            self?.view.layoutIfNeeded()
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
