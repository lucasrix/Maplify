//
//  StoryInfoCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/8/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryInfoCell: CSCollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var storyPointsCountLabel: UILabel!
    
    override func configure(cellData: CSCellData) {
        let story = cellData.model as! Story
        self.populateStoryPointsCount(story)
        self.populateBackgroundImage(story)
    }
    
    func populateStoryPointsCount(story: Story) {
        self.storyPointsCountLabel.text = "\(story.storyPoints.count) " + NSLocalizedString("Substring.Points", comment: String())
    }
    
    func populateBackgroundImage(story: Story) {
        let storyPoint: StoryPoint = story.storyPoints.first!
        let imageUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholderAttachment)
        self.backgroundImageView.sd_setImageWithURL(imageUrl, placeholderImage: placeholderImage)
    }
}
