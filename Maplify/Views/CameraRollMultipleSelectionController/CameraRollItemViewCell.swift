//
//  CameraRollItemViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

let kDoubleTime60: Double = 60

class CameraRollItemViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var isVideoImageView: UIImageView!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    var imageManager = PHCachingImageManager()
    
    func configure(asset: PHAsset, targetSize: CGSize, selected: Bool) {
        self.updateSelection(selected)
        self.populateImage(asset, targetSize: targetSize)
        self.populateVideoIfNeeded(asset, targetSize: targetSize)
    }
    
    func updateSelection(selected: Bool) {
        self.contentView.backgroundColor = selected ? UIColor.dodgerBlue() : UIColor.clearColor()
        self.checkedImageView.hidden = !selected
    }
    
    func populateImage(asset: PHAsset, targetSize: CGSize) {
        AssetRetrievingManager.retrieveImage(asset, targetSize: targetSize) { [weak self] (result, info) in
            self?.imageView.image = result
            self?.isVideoImageView.hidden = asset.mediaType == .Image
            self?.timeLabel.hidden = asset.mediaType == .Image
        }
    }
    
    func populateVideoIfNeeded(asset: PHAsset, targetSize: CGSize) {
        if asset.mediaType == .Video {
            self.populateVideo(asset)
        }
    }
    
    private func populateVideo(asset: PHAsset) {
        AssetRetrievingManager.retrieveVideoAsset(asset) { [weak self] (avAsset, audioMix, info) in
            let videoDuration = (avAsset?.duration.seconds)!
            self?.timeLabel.text = videoDuration.toTimeString()
        }
    }
}

private extension Double {
    func toTimeString() -> String {
        let minutes = Int(self / kDoubleTime60)
        let seconds = Int(self) - minutes * Int(kDoubleTime60)
        return String(format: "\(minutes):%02d", seconds)
    }
}
