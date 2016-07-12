//
//  StoryAddMediaTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

let kCellTopMargin: CGFloat = 24
let kCellLocationViewHeight: CGFloat = 39
let kCellDescriptionViewHeight: CGFloat = 73

class StoryAddMediaTableViewCell: CSTableViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var imageManager = PHCachingImageManager()
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.setupViews()
        
        let asset = cellData.model as! PHAsset
        self.populateImage(asset)
    }
    
    func setupViews() {
        self.imageViewHeightConstraint.constant = UIScreen().screenWidth()
    }
    
    func populateImage(asset: PHAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let targetSize = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
            self.imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) { [weak self] (result, info) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self?.assetImageView.image = result
                })
            }
        })
    }
    
    class func contentHeight() -> CGFloat {
        let imageViewHeight: CGFloat = UIScreen().screenWidth()
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
}
