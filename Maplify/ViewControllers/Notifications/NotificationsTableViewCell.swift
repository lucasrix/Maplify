//
//  NotificationsTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kNotificationAttributedMessageDefaultFontSize: CGFloat = 14
let kNotificationMessageAlphaComponentDefault: CGFloat = 0.4
let kNotificationMessageAlphaComponentHighlited: CGFloat = 1

class NotificationsTableViewCell: CSTableViewCell {
    @IBOutlet weak var userThumbImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificableItemImageView: UIImageView!
    
    var actionUserId: Int = 0
    var delegate: NotificationsCellDelegate! = nil
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let notification = cellData.model as! Notification
        
        self.actionUserId = notification.action_user.id
        self.delegate = cellData.delegate as! NotificationsCellDelegate
        
        self.setupViews()
        self.populateActionUserViews(notification.action_user)
        self.populateMessageViews(notification)
        self.populateNotificableItemIfNeeded(notification)
    }
    
    func setupViews() {
        self.userThumbImageView.layer.cornerRadius = CGRectGetWidth(self.userThumbImageView.frame) / 2
    }
    
    func populateActionUserViews(actionUser: User) {
        let profile = actionUser.profile as Profile
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.userThumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NotificationsTableViewCell.profileImageTapped))
        self.userThumbImageView.addGestureRecognizer(tapGesture)
    }
    
    func populateMessageViews(notification: Notification) {
        self.messageLabel.attributedText = self.messageText(notification)
        self.dateLabel.text = self.dateText(notification)
    }
    
    func populateNotificableItemIfNeeded(notification: Notification) {
        // TODO:
    }
    
    // MARK: - private
    func profileImageTapped() {
        self.delegate?.openProfile(self.actionUserId)
    }
    
    func messageText(notification: Notification) -> NSMutableAttributedString {
        let userSubstring = (notification.action_user?.profile.firstName)! + " " + (notification.action_user?.profile.lastName)!
        let messageSubstring = notification.message
        var notificableItemSubstring = String()
        
        if notification.notificable_type == NotificableType.StoryPoint.rawValue {
            notificableItemSubstring = (notification.notificable_storypoint?.caption)!
        } else if notification.notificable_type == NotificableType.Story.rawValue {
            notificableItemSubstring = (notification.notificable_story?.title)!
        }
        
        let resultString = userSubstring + " " + messageSubstring + " " + notificableItemSubstring
        
        let attributedMessage = NSMutableAttributedString(string: resultString)
        attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor().colorWithAlphaComponent(kNotificationMessageAlphaComponentDefault), range: NSMakeRange(0, NSString(string: attributedMessage.string).length))
        
        let usernameRange = (resultString as NSString).rangeOfString(userSubstring)
        attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationMessageAlphaComponentHighlited), range: usernameRange)
        attributedMessage.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(kNotificationAttributedMessageDefaultFontSize), range: usernameRange)
        
        if notificableItemSubstring.length > 0 {
            let notificableItemRange = (resultString as NSString).rangeOfString(notificableItemSubstring)
            attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationMessageAlphaComponentHighlited), range: notificableItemRange)
            attributedMessage.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(kNotificationAttributedMessageDefaultFontSize), range: notificableItemRange)
        }
        
        return attributedMessage
    }
    
    func dateText(notification: Notification) -> String {
        let date = notification.created_at.toDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = DateFormats.notificationFormat
        return dateFormatter.stringFromDate(date!)
    }
}

protocol NotificationsCellDelegate {
    func openProfile(userId: Int)
}
