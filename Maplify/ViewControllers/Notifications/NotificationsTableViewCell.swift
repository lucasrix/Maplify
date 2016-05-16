//
//  NotificationsTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: CSTableViewCell {
    @IBOutlet weak var userThumbImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificableItemImageView: UIImageView!
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let notification = cellData.model as! Notification
        
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
    }
    
    func populateMessageViews(notification: Notification) {
        // TODO:
    }
    
    func populateNotificableItemIfNeeded(notification: Notification) {
        // TODO:
    }
}
