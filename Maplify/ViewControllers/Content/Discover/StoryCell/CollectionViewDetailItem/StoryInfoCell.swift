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
        let localizedString = NSString.localizedStringWithFormat(NSLocalizedString("Count.Storypoints", comment: String()), story.storyPoints.count)
        self.storyPointsCountLabel.text = String(localizedString)
    }
    
    func populateBackgroundImage(story: Story) {
        let storyPoint: StoryPoint = story.storyPoints.first!
        if storyPoint.location != nil {
            let imageUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthSmall)
            self.backgroundImageView.sd_setImageWithURL(imageUrl)
        }
    }
}
