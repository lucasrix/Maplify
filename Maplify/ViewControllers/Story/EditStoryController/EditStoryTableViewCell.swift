//
//  EditStoryTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class EditStoryTableViewCell: CSTableViewCell {

    override func configure(cellData: CSCellData) {
        let storyPoint = cellData.model as! StoryPoint
        print(storyPoint.id)
    }
}
