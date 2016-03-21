//
//  StoryPointEditDescriptionViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDescriptionTextViewMaxCharactersCount = 1500

class StoryPointEditDescriptionViewController: ViewController, UITextViewDelegate {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var type: String! = nil
    
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
        self.setupViews()
        self.subscribeNotifications()
        self.descriptionTextView.delegate = self
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.StoryPointEditDescription.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
        self.updateCharactersCountLabel(0 as Int)
    }
    
    // MARK: - notifications/observers
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
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
    
    // MARK: - navigation bar item actions
    override func rightBarButtonItemDidTap() {
        // TODO:
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
    
    // MARK: - private
    func updateCharactersCountLabel(charactersCount: Int) {
        let substringOf = NSLocalizedString("Substring.Of", comment: String())
        let substringChars = NSLocalizedString("Substring.Chars", comment: String())
        self.charactersCountLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
    }
}
