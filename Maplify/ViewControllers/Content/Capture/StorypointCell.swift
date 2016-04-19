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
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.setupRoundedView()
        
        let storyPoint = cellData.model as! StoryPoint
        self.setupLabels(storyPoint)
        self.setupStoryImage(storyPoint)
        self.setupStoryPointImage(storyPoint)
    }
    
    func setupRoundedView() {
        self.roundedView.layer.cornerRadius = CornerRadius.defaultRadius
        self.roundedView.layer.masksToBounds = true
    }
    
    func setupImageView(image: UIImage!) {
        self.storyPointImageView.image = image
    }
    
    func setupLabels(storyPoint: StoryPoint) {
        self.titleLabel.text = storyPoint.caption
        
        let profile = storyPoint.user.profile
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
        
        self.addressLabel.text = storyPoint.location.city
    }
    
    func setupStoryImage(storyPoint: StoryPoint) {
        self.storyImage.hidden = !(storyPoint.story != nil)
    }
    
    func setupStoryPointImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointImageView.image = UIImage(named: CellImages.textStoryPoint)
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointImageView.image = UIImage(named: CellImages.audioStoryPoint)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointImageView.image = UIImage(named: CellImages.videoStoryPoint)
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointImageView.image = UIImage(contentsOfFile: storyPoint.attachment.file_url)
        }
        self.storyPointImageView.layer.cornerRadius = CornerRadius.defaultRadius
    }
}