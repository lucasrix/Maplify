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

let kShadowOpacity: Float = 0.15
let kShadowRadius: CGFloat = 3

let kTopInfoViewHeight: CGFloat = 103
let kBottomInfoView: CGFloat = 70
let kStoryPointTextFontSize: CGFloat = 14
let kStoryPointTextHorizontalMargin: CGFloat = 16
let kStoryPointTextVerticalMargin: CGFloat = 13

class DiscoverStoryPointCell: CSTableViewCell {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var storyPointAddressLabel: UILabel!
    @IBOutlet weak var storyPointAddressImageView: UIImageView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionButton: UIButton!
    @IBOutlet weak var backShadowView: UIView!
    @IBOutlet weak var attachmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentContentView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    
    var cellData: CSCellData! = nil
    var delegate: DiscoverStoryPointCellDelegate! = nil
    var discoverItemId: Int = 0
    var storyPointId: Int = 0
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.cellData = cellData
        self.delegate = cellData.delegate as! DiscoverStoryPointCellDelegate
        let item = cellData.model as! DiscoverItem
        let storyPoint = item.storyPoint
        self.discoverItemId = item.id
        self.storyPointId = storyPoint!.id
        
        self.addShadow()
        self.populateUserViews(storyPoint!)
        self.populateStoryPointInfoViews(storyPoint!)
        self.populateAttachment(storyPoint!)
        self.populateDescriptionLabel(cellData)
        self.populateLikeButton()
        self.setupGestures()
    }
    
    func addShadow() {
        self.backShadowView?.layer.shadowColor = UIColor.blackColor().CGColor
        self.backShadowView?.layer.shadowOpacity = kShadowOpacity
        self.backShadowView?.layer.shadowOffset = CGSizeZero
        self.backShadowView?.layer.shadowRadius = kShadowRadius
    }
    
    func populateUserViews(storyPoint: StoryPoint) {
        let user = storyPoint.user as User
        let profile = user.profile as Profile
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.thumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DiscoverStoryPointCell.profileImageTapped))
        self.thumbImageView.addGestureRecognizer(tapGesture)
        
        self.usernameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city
    }
    
    func populateStoryPointInfoViews(storyPoint: StoryPoint) {
        self.storyPointAddressLabel.text = storyPoint.location.address
        self.storyPointAddressImageView.hidden = storyPoint.location.address == String()
    }
    
    func populateAttachment(storyPoint: StoryPoint) {
        var attachmentUrl: NSURL! = nil
        var placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.attachmentHeightConstraint.constant = UIScreen().screenWidth()
            attachmentUrl = storyPoint.attachment.file_url.url
        } else if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.attachmentHeightConstraint.constant = 0.0
            attachmentUrl = nil
            placeholderImage = nil
        } else {
            self.attachmentHeightConstraint.constant = UIScreen().screenWidth()
            attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        }
        self.attachmentImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if error == nil {
                self?.colorView.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
            }
            self?.populateKindImage(storyPoint)
        }
    }
    
    func populateKindImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = nil
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = nil
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        }
        self.storyPointKindImageView.hidden = storyPoint.kind == StoryPointKind.Text.rawValue || storyPoint.kind == StoryPointKind.Photo.rawValue
    }
    
    func populateDescriptionLabel(cellData: CSCellData) {
        let item = cellData.model as! DiscoverItem
        let storyPoint = item.storyPoint
        
        self.descriptionLabel.text = storyPoint!.text
        
        if cellData.selected || storyPoint?.kind == StoryPointKind.Text.rawValue {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
            self.textHeightConstraint.constant = DiscoverStoryPointCell.textDescriptionHeight((storyPoint?.text)!, width: cellData.boundingSize.width)
        } else {
            self.textHeightConstraint.constant = kStoryPointCellDescriptionDefaultHeight
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(storyPoint!.text) || storyPoint?.kind == StoryPointKind.Text.rawValue
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(storyPoint!.text) || storyPoint?.kind == StoryPointKind.Text.rawValue
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DiscoverStoryPointCell.openContentTapHandler(_:)))
        self.attachmentContentView?.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.delegate?.reloadTable(self.discoverItemId)
    }
    
    @IBAction func editContentTapped(sender: AnyObject) {
        self.delegate?.editContentDidTap(self.storyPointId)
    }
    
    func profileImageTapped() {
        let item = self.cellData.model as! DiscoverItem
        let storyPoint = item.storyPoint
        self.delegate?.profileImageTapped(storyPoint!.user.id)
    }
    
    @IBAction func likeTapped(sender: UIButton) {
        self.likeButton.enabled = false
        self.delegate?.likeStoryPointDidTap(self.storyPointId, completion: { [weak self] (success) in
            self?.likeButton.enabled = true
            if success {
                self?.populateLikeButton()
            }
        })
    }
    
    @IBAction func shareTapped(sender: UIButton) {
        self.delegate?.shareStoryPointDidTap(self.storyPointId)
    }
    
    // MARK: - gestures
    func openContentTapHandler(gestureRecognizer: UIGestureRecognizer) {
        let item = self.cellData.model as! DiscoverItem
        let storyPoint = item.storyPoint
        if storyPoint?.kind == StoryPointKind.Video.rawValue {
            PlayerHelper.sharedPlayer.playVideo((storyPoint?.attachment.file_url)!, onView: self.attachmentContentView)
        } else if storyPoint?.kind == StoryPointKind.Audio.rawValue {
            PlayerHelper.sharedPlayer.playAudio((storyPoint?.attachment?.file_url)!, onView: self.attachmentContentView)
        }
        self.attachmentContentView.hidden = storyPoint?.kind == StoryPointKind.Text.rawValue || storyPoint?.kind == StoryPointKind.Photo.rawValue
    }
    
    func cellDidEndDiplaying() {
        PlayerHelper.sharedPlayer.removeVideoPlayerIfNedded()
    }

    // MARK: - private
    func showHideButtonHidden(text: String) -> Bool {
        let font = self.descriptionLabel.font
        let textWidth: CGFloat = CGRectGetWidth(self.descriptionLabel.frame)
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        return textSize.height <= kStoryPointCellDescriptionDefaultHeight
    }
    
    func populateLikeButton() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint.liked {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLikeHighlited), forState: .Normal)
        } else {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLike), forState: .Normal)
        }
    }
    
    // MARK: - content height
    class func contentSize(cellData: CSCellData) -> CGSize {
        let contentWidth: CGFloat = cellData.boundingSize.width
        var contentHeight: CGFloat = kTopInfoViewHeight + kBottomInfoView
        
        let item = cellData.model as! DiscoverItem
        let storyPoint = item.storyPoint
        if storyPoint?.kind != StoryPointKind.Text.rawValue {
            contentHeight += cellData.boundingSize.width
        }

        if cellData.selected || storyPoint?.kind == StoryPointKind.Text.rawValue {
            contentHeight += DiscoverStoryPointCell.textDescriptionHeight((storyPoint?.text)!, width: contentWidth)
        } else {
            contentHeight += kStoryPointCellDescriptionDefaultHeight
        }
        
        contentHeight += kStoryPointTextVerticalMargin
        return CGSizeMake(contentWidth, contentHeight)
    }
    
    class func textDescriptionHeight(text: String, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFontOfSize(kStoryPointTextFontSize)
        let textBoundingWidth = width - 2 * kStoryPointTextHorizontalMargin
        return CGFloat(ceil(text.size(font, boundingRect: CGRect(x: 0, y: 0, width: textBoundingWidth, height: CGFloat.max)).height))
    }
}

protocol DiscoverStoryPointCellDelegate {
    func reloadTable(storyPointId: Int)
    func editContentDidTap(storyPointId: Int)
    func profileImageTapped(userId: Int)
    func likeStoryPointDidTap(storyPointId: Int, completion: ((success: Bool) -> ()))
    func shareStoryPointDidTap(storyPointId: Int)
}
