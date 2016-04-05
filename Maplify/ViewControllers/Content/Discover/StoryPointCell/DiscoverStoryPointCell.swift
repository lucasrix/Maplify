//
//  DiscoverStoryPointCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import SDWebImage.UIImageView_WebCache

let kHeightUserInfoView: CGFloat = 66
let kHeightStoryPointInfoView: CGFloat = 60
let kHeightDescriptionView: CGFloat = 30
let kHeightDescriptionTop: CGFloat = 10
let kHeightActionsView: CGFloat = 46

class DiscoverStoryPointCell: CSTableViewCell {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var storyPointAddressLabel: UILabel!
    @IBOutlet weak var storyPointAddressImageView: UIImageView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func configure(cellData: CSCellData) {
        
        let storyPoint = cellData.model as! StoryPoint
        self.populateUserViews(storyPoint)
        self.populateStoryPointInfoViews(storyPoint)
        self.populateAttachment(storyPoint)
        self.populateDescriptionLabel(storyPoint)
    }
    
    func populateUserViews(storyPoint: StoryPoint) {
        let user = storyPoint.user as User
        let profile = user.profile as Profile
        if profile.photo.length > 0 {
            let userPhotoUrl:NSURL? = NSURL(string: profile.photo)
            self.thumbImageView.hnk_setImageFromURL(userPhotoUrl!)
        } else {
            self.thumbImageView.image = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        }
        
        self.usernameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city
    }
    
    func populateStoryPointInfoViews(storyPoint: StoryPoint) {
        self.captionLabel.text = storyPoint.caption
    }
    
    func populateAttachment(storyPoint: StoryPoint) {
        
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            
            if storyPoint.attachment.file_url.length > 0 {
                self.attachmentImageView.sd_setImageWithURL(storyPoint.attachment.file_url.url)
            } else {
                self.attachmentImageView.image = UIImage(named: PlaceholderImages.discoverPlaceholderAttachment)
            }
        } else {
            self.attachmentImageView.image = nil
        }
    }
    
    func populateDescriptionLabel(storyPoint: StoryPoint) {
        self.descriptionLabel.text = storyPoint.text
    }
    
    class func contentHeightForStoryPoint(storyPoint: StoryPoint) -> CGFloat {
        var cellHeight: CGFloat = 0
        cellHeight += kHeightUserInfoView
        cellHeight += kHeightStoryPointInfoView
        cellHeight += kHeightDescriptionView
        cellHeight += kHeightActionsView
        if storyPoint.kind != StoryPointKind.Text.rawValue {
            let attachmentContentHeight = UIScreen.mainScreen().bounds.width
            cellHeight += attachmentContentHeight
        }
        return cellHeight
    }
}
