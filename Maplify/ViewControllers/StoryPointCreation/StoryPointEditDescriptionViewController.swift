//
//  StoryPointEditDescriptionViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointEditDescriptionViewController: ViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
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
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.StoryPointEditDescription.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
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
}
