//
//  StoryPointDetailCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointDetailCell: CSCollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    var googleMapService: GoogleMapService! = nil
    
    override func configure(cellData: CSCellData) {
        let storyPoint = cellData.model as! StoryPoint
        self.populateBackgroundImage(storyPoint)
        self.populateKindImage(storyPoint)
    }

    func populateBackgroundImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            let attachment = storyPoint.attachment as Attachment
            let attachmentUrl = NSURL(string: attachment.file_url)
            let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholderAttachment)
            self.backgroundImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage)
        } else {
            self.downloadMapImage(storyPoint.location)
        }
        self.colorView.hidden = storyPoint.kind == StoryPointKind.Photo.rawValue
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
    
    func downloadMapImage(location: Location) {
        let imageUrl = StaticMap.staticMapUrl(location.latitude, longitude: location.longitude)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholderAttachment)
        self.backgroundImageView.sd_setImageWithURL(imageUrl, placeholderImage: placeholderImage)
    }
}
