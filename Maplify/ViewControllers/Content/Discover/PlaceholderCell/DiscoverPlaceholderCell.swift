//
//  DiscoverPlaceholderCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDiscoverPlaceholderCellHeight: CGFloat = 250

class DiscoverPlaceholderCell: CSTableViewCell {
    @IBOutlet weak var placeholderLabel: UILabel!
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let model = cellData.model
        if model is String {
            let placeholder = model as! String
            self.placeholderLabel.text = placeholder
        }
    }
    
    // MARK: - content height
    class func contentSize(cellData: CSCellData) -> CGSize {
        let contentWidth: CGFloat = cellData.boundingSize.width
        let contentHeight: CGFloat = kDiscoverPlaceholderCellHeight
        
        return CGSizeMake(contentWidth, contentHeight)
    }
}
