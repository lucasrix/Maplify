//
//  DetailStoryNumberCell.swift
//  Maplify
//
//  Created by Sergei on 30/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class DetailStoryNumberCell: CSCollectionViewCell {
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
        let storyPoint: StoryPoint! = story.storyPoints.count > 0 ? story.storyPoints.first!: nil
        if storyPoint?.location != nil {
            let imageUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthSmall, showWholeWorld: false)
            self.backgroundImageView.sd_setImageWithURL(imageUrl)
        }
    }
}