//
//  StoryLinkCell.swift
//  Maplify
//
//  Created by jowkame on 5/29/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class StoryLinkCell: CSTableViewCell {
    @IBOutlet weak var storyNameLabel: UILabel!
    
    override func configure(cellData: CSCellData) {
        self.selectionStyle = .None
        
        let storyLink = cellData.model as! StoryLink
        self.storyNameLabel.text = storyLink.name
    }
}
