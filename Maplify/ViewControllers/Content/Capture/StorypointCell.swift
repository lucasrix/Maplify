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
    @IBOutlet weak var blurHostView: UIView!
    
    override func configure(cellData: CSCellData) {
        self.setupRoundedView()
        self.setupImageView(UIImage(named: CellImages.textStoryPoint))
        
        let storyPoint = cellData.model as! StoryPoint
        self.titleLabel.text = storyPoint.caption
        
        let profile = storyPoint.user.profile
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
    }
    
    func setupRoundedView() {
        self.roundedView.layer.cornerRadius = CornerRadius.defaultRadius
        self.roundedView.layer.masksToBounds = true
    }
    
    func setupImageView(image: UIImage!) {
        self.storyPointImageView.image = image
        self.storyPointImageView.layer.cornerRadius = CornerRadius.defaultRadius
    }
}