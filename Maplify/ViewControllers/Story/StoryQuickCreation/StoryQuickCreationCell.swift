//
//  StoryQuickCreationCell.swift
//  Maplify
//
//  Created by - Jony - on 3/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class StoryQuickCreationCell: CSTableViewCell {
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyPointsCountLabel: UILabel!
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.selectionStyle = .None
        
        let story = cellData.model as! Story
        self.titleLabel.text = story.title
        self.storyPointsCountLabel.text = String(story.storyPoints.count)
        self.selectionImageView.image = (cellData.selected) ? UIImage(named: CellImages.selectedCircle) : UIImage(named: CellImages.emptyCircle)
    }
}
