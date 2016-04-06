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
let kHeightDescriptionLabel: CGFloat = 17
let kHeightDescriptionTop: CGFloat = 13
let kHeightActionsView: CGFloat = 46
let kHeightBottomConstraint: CGFloat = 24
let kDescriptionLeftRightMargin: CGFloat = 16
let kDescriptionLabelFontSize: CGFloat = 14
let kShadowOpacity: Float = 0.15
let kShadowRadius: CGFloat = 3

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
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showHideDescriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionButton: UIButton!
    @IBOutlet weak var backShadowView: UIView!
    
    var cellData: CSCellData! = nil
    var delegate: DiscoverStoryPointCellDelegate! = nil
    var storyPointId: Int = 0
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.setupViews()
        
        self.cellData = cellData
        self.delegate = cellData.delegate as! DiscoverStoryPointCellDelegate
        let storyPoint = cellData.model as! StoryPoint
        self.storyPointId = storyPoint.id
        
        self.populateUserViews(storyPoint)
        self.populateStoryPointInfoViews(storyPoint)
        self.populateAttachment(storyPoint)
        self.populateDescriptionLabel(cellData)
    }
    
    func setupViews() {
        self.backShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.backShadowView.layer.shadowOpacity = kShadowOpacity
        self.backShadowView.layer.shadowOffset = CGSizeZero
        self.backShadowView.layer.shadowRadius = kShadowRadius
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
        } else if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.attachmentImageView.image = nil
        } else {
            self.attachmentImageView.image = UIImage(named: PlaceholderImages.discoverPlaceholderAttachment)
        }
    }
    
    func populateDescriptionLabel(cellData: CSCellData) {
        let storyPoint = cellData.model as! StoryPoint
        self.descriptionLabel.text = storyPoint.text
        if cellData.selected {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
            self.descriptionViewHeightConstraint.constant = DiscoverStoryPointCell.textHeight(cellData) + kHeightDescriptionTop
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
            self.descriptionViewHeightConstraint.constant = kHeightDescriptionLabel + kHeightDescriptionTop
        }
        self.showHideDescriptionLabel.hidden = DiscoverStoryPointCell.textHeight(cellData) <= kHeightDescriptionLabel
        self.showHideDescriptionButton.hidden = DiscoverStoryPointCell.textHeight(cellData) <= kHeightDescriptionLabel
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.cellData.selected = !self.cellData.selected
        self.delegate?.reloadTable(self.storyPointId)
    }
    
    @IBAction func editContentTapped(sender: AnyObject) {
        self.delegate?.editContentDidTap()
    }
    
    // MARK: - class func
    class func contentHeightForStoryPoint(cellData: CSCellData) -> CGFloat {
        let storyPoint = cellData.model as! StoryPoint
        var cellHeight: CGFloat = 0
        cellHeight += kHeightUserInfoView
        cellHeight += kHeightStoryPointInfoView
        cellHeight += kHeightActionsView
        if storyPoint.kind != StoryPointKind.Text.rawValue {
            cellHeight += UIScreen.mainScreen().bounds.width
        }
        if cellData.selected {
            cellHeight += self.textHeight(cellData)
        } else {
            cellHeight += kHeightDescriptionLabel
        }
        cellHeight += kHeightDescriptionTop
        cellHeight += kHeightBottomConstraint
        
        return cellHeight
    }
    
    class func textHeight(cellData: CSCellData) -> CGFloat {
        let storyPoint = cellData.model as! StoryPoint
        let text = storyPoint.text
        let font = UIFont.systemFontOfSize(kDescriptionLabelFontSize)
        let textWidth: CGFloat = UIScreen().screenWidth() - 2 * kDescriptionLeftRightMargin
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        let textHeight = CGFloat(ceil(Double(textSize.height)))
        if textHeight > kHeightDescriptionLabel {
            return textHeight
        }
        return kHeightDescriptionLabel
    }
}

protocol DiscoverStoryPointCellDelegate {
    func reloadTable(storyPointId: Int)
    func editContentDidTap()
}
