//
//  StoryPointEditDescriptionViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import GoogleMaps
import UIKit

let kDescriptionTextViewMaxCharactersCount = 1500

class StoryPointEditDescriptionViewController: ViewController, UITextViewDelegate {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var storyPointKind: StoryPointKind! = nil
    var storyPointAttachmentId: Int = 0
    var location: MCMapCoordinate! = nil
    var locationString = String()
    var selectedStoryIds: [Int]! = nil
    var creationPostCompletion: creationPostClosure!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.descriptionTextView.becomeFirstResponder()
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
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
        self.updateCharactersCountLabel(0 as Int)
    }
    
    // MARK: - notifications/observers
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoryPointEditDescriptionViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
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
        if self.descriptionTextView.text.isNonWhiteSpace {
            self.remotePostStoryPoint()
        } else {
            let messasge = NSLocalizedString("Alert.EnterDescription", comment: String())
            let cancel = NSLocalizedString("Button.Ok", comment: String())
            self.showMessageAlert(nil, message: messasge, cancel: cancel)
        }
    }
    
    // MARK: - private
    func remotePostStoryPoint() {
        self.descriptionTextView.resignFirstResponder()
        self.showProgressHUD()
        var locationDict: [String: AnyObject] = ["latitude":self.location.latitude, "longitude":self.location.longitude]
        if self.locationString.length > 0 {
            locationDict["address"] = self.locationString
        }
        let kind = self.storyPointKind.rawValue
        var storyPointDict: [String: AnyObject] = ["kind":kind,
                                                   "text":self.descriptionTextView.text,
                                                   "location":locationDict]
        if self.storyPointKind != StoryPointKind.Text {
            storyPointDict["attachment_id"] = self.storyPointAttachmentId
        }
        if self.selectedStoryIds.count > 0 {
            storyPointDict["story_ids"] = self.selectedStoryIds
        }
        
        ApiClient.sharedClient.createStoryPoint(storyPointDict, success: { [weak self] (response) -> () in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            let storyPointId = (response as! StoryPoint).id
            self?.retrieveUserStories(storyPointId)
        }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
            self?.hideProgressHUD()
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func retrieveUserStories(storyPointId: Int) {
        ApiClient.sharedClient.getUserStories(SessionManager.currentUser().id,
                                              success: { [weak self] (response) in
                                                StoryManager.saveStories(response as! [Story])
                                                self?.hideProgressHUD()
                                                self?.creationPostCompletion?(storyPointId: storyPointId)
                                                self?.navigationController?.popToRootViewControllerAnimated(true)
            }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
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
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
