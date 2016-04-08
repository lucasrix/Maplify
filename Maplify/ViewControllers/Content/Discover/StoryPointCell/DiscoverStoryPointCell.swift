//
//  DiscoverStoryPointCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import SDWebImage.UIImageView_WebCache

let kStoryPointCellDescriptionDefaultHeight: CGFloat = 17
let kStoryPointDescriptionOpened: Int = 0
let kStoryPointDescriptionClosed: Int = 1

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
    @IBOutlet weak var showHideDescriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionButton: UIButton!
    @IBOutlet weak var backShadowView: UIView!
    
    var cellData: CSCellData! = nil
    var delegate: DiscoverStoryPointCellDelegate! = nil
    var storyPointId: Int = 0
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.cellData = cellData
        self.delegate = cellData.delegate as! DiscoverStoryPointCellDelegate
        let storyPoint = cellData.model as! StoryPoint
        self.storyPointId = storyPoint.id
        
        self.addShadow()
        self.populateUserViews(storyPoint)
        self.populateStoryPointInfoViews(storyPoint)
        self.populateAttachment(storyPoint)
        self.populateDescriptionLabel(cellData)
    }
    
    func addShadow() {
        self.backShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.backShadowView.layer.shadowOpacity = kShadowOpacity
        self.backShadowView.layer.shadowOffset = CGSizeZero
        self.backShadowView.layer.shadowRadius = kShadowRadius
    }
    
    func populateUserViews(storyPoint: StoryPoint) {
        let user = storyPoint.user as User
        let profile = user.profile as Profile
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.photo)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.thumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        self.usernameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city != "" ? profile.city : "Washington DC"
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
        self.descriptionLabel.numberOfLines = cellData.selected ? kStoryPointDescriptionOpened : kStoryPointDescriptionClosed
        let storyPoint = cellData.model as! StoryPoint
        
        let rrr = "okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc okcoekcoekokc "
        self.descriptionLabel.text = rrr//storyPoint.text
        
        if cellData.selected {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(rrr)
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(rrr)
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.cellData.selected = !self.cellData.selected
        self.delegate?.reloadTable(self.storyPointId)
    }
    
    @IBAction func editContentTapped(sender: AnyObject) {
        self.delegate?.editContentDidTap(self.storyPointId)
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
    }

    // MARK: - private
    func showHideButtonHidden(text: String) -> Bool {
        let font = self.descriptionLabel.font
        let textWidth: CGFloat = CGRectGetWidth(self.descriptionLabel.frame)
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        return textSize.height <= kStoryPointCellDescriptionDefaultHeight
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
        // need to use to set the preferredMaxLayoutWidth below.
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
        // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
        self.usernameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.usernameLabel.frame)
        self.captionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.captionLabel.frame)
        self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame)
    }
}

protocol DiscoverStoryPointCellDelegate {
    func reloadTable(storyPointId: Int)
    func editContentDidTap(storyPointId: Int)
}
