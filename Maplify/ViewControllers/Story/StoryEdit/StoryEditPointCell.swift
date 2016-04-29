//
//  StoryEditPointCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryEditPointCell: CSTableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var storyPointTitleLabel: UILabel!
    @IBOutlet weak var storyPointAddressLabel: UILabel!
    @IBOutlet weak var storyPointAddressImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let storyPoint = cellData.model as! StoryPoint
        self.setupViews()
        self.populateViews(storyPoint)
    }

    func setupViews() {
        self.backView.layer.cornerRadius = CornerRadius.defaultRadius
        self.backView.clipsToBounds = true
        self.backView.layer.borderWidth = Border.defaultBorderWidth
        self.backView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.attachmentImageView.layer.cornerRadius = CornerRadius.defaultRadius
        self.attachmentImageView.clipsToBounds = true
        self.attachmentImageView.layer.borderWidth = Border.defaultBorderWidth
        self.attachmentImageView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.colorView.layer.cornerRadius = CornerRadius.defaultRadius
        self.colorView.clipsToBounds = true
        self.colorView.layer.borderWidth = Border.defaultBorderWidth
        self.colorView.layer.borderColor = UIColor.inactiveGrey().CGColor
    }
    
    func populateViews(storyPoint: StoryPoint) {
        self.populateTitle(storyPoint)
        self.populateAddress(storyPoint)
        self.populateUserName(storyPoint)
        self.populateImageView(storyPoint)
    }
    
    func populateTitle(storyPoint: StoryPoint) {
        self.storyPointTitleLabel.text = storyPoint.caption
    }
    
    func populateAddress(storyPoint: StoryPoint) {
        self.storyPointAddressLabel.text = storyPoint.location.address
        self.storyPointAddressImageView.hidden = storyPoint.location.address == String()
    }
    
    func populateUserName(storyPoint: StoryPoint) {
        self.userNameLabel.text = storyPoint.user.profile.firstName + " " + storyPoint.user.profile.lastName
    }
    
    func populateImageView(storyPoint: StoryPoint) {
        var attachmentUrl: NSURL! = nil
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            if storyPoint.attachment != nil {
                let attachment = storyPoint.attachment as Attachment
                attachmentUrl = NSURL(string: attachment.file_url)
            }
        } else {
            if storyPoint.location != nil {
                attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthSmall)
            }
        }
        self.attachmentImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if !(error != nil) {
                self?.colorView.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
                self?.populateKindImage(storyPoint)
            }
        }
    }
    
    func populateKindImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconText)
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = UIImage()
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        }
    }
}
