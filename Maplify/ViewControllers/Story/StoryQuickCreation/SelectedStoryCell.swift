//
//  SelectedStoryCell.swift
//  Maplify
//
//  Created by jowkame on 01.04.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

protocol SelectedStoryCellProtocol {
    func willDeleteStory(storyId: Int)
}

class SelectedStoryCell: CSTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyPointsCountLabel: UILabel!
    
    var delegate: SelectedStoryCellProtocol! = nil
    var storyId: Int = 0
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.selectionStyle = .None
        
        let story = cellData.model as! Story
        self.titleLabel.text = story.title
        self.storyPointsCountLabel.text = String(story.storyPoints.count)
        
        self.storyId = story.id
        self.delegate = cellData.delegate as! SelectedStoryCellProtocol
    }
    
    // MARK: - actions
    @IBAction func deleteButtonDidTap(sender: AnyObject) {
        self.delegate?.willDeleteStory(self.storyId)
    }
    
}