//
//  StorypointCell.swift
//  Maplify
//
//  Created by Sergey on 3/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class StorypointCell: CSCollectionViewCell {
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.setupRoundedView()
        
        let storyPoint = cellData.model as! StoryPoint
        self.setupLabels(storyPoint)
        self.setupStoryImage(storyPoint)
        self.populateImageView(storyPoint)
    }
    
    func setupRoundedView() {
        self.roundedView.layer.cornerRadius = CornerRadius.defaultRadius
        self.roundedView.layer.masksToBounds = true
        
        self.colorView.layer.cornerRadius = CornerRadius.defaultRadius
        self.colorView.clipsToBounds = true
    }
    
    func setupImageView(image: UIImage!) {
        self.storyPointImageView.image = image
    }
    
    func setupLabels(storyPoint: StoryPoint) {
        self.titleLabel.text = storyPoint.caption
        
        let profile = storyPoint.user.profile
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
        
        self.addressLabel.text = storyPoint.location.address
    }
    
    func setupStoryImage(storyPoint: StoryPoint) {
        self.storyImage.hidden = !(storyPoint.story != nil)
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
        self.storyPointImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if !(error != nil) {
                self?.colorView.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
                self?.populateKindImage(storyPoint)
            }
        }
    }
    
    func populateKindImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconText)
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = UIImage()
        }
        self.storyPointImageView.layer.cornerRadius = CornerRadius.defaultRadius
    }
}