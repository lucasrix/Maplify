//
//  DetailStoryPointCollectionCell.swift
//  Maplify
//
//  Created by Sergei on 30/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class DetailStoryPointCollectionCell: CSCollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    var googleMapService: GoogleMapService! = nil
    
    override func configure(cellData: CSCellData) {
        let storyPoint = cellData.model as! StoryPoint
        self.populateBackgroundImage(storyPoint)
    }
    
    func populateBackgroundImage(storyPoint: StoryPoint) {
        var attachmentUrl: NSURL! = nil
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            if storyPoint.attachment != nil {
                let attachment = storyPoint.attachment as Attachment
                attachmentUrl = NSURL(string: attachment.file_url)
            }
        } else {
            if storyPoint.location != nil {
                attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthSmall, showWholeWorld: false)
            }
        }
        self.backgroundImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if error == nil {
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