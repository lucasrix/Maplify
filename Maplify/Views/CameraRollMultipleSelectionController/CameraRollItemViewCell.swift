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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) { [weak self] (result, info) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self?.imageView.image = result
                    self?.isVideoImageView.hidden = asset.mediaType == .Image
                    self?.timeLabel.hidden = asset.mediaType == .Image
                })
            }
        })
    }
    
    func populateVideoIfNeeded(asset: PHAsset, targetSize: CGSize) {
        if asset.mediaType == .Video {
            self.populateVideo(asset, targetSize: targetSize)
        }
    }
    
    private func populateVideo(asset: PHAsset, targetSize: CGSize) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let options = PHVideoRequestOptions()
            options.networkAccessAllowed = true
            self.imageManager.requestAVAssetForVideo(asset, options: options, resultHandler: { [weak self] (avAsset, audioMix, info) -> () in
                
                dispatch_async(dispatch_get_main_queue(), {
                    let videoDuration = (avAsset?.duration.seconds)!
                    self?.timeLabel.text = videoDuration.toTimeString()
                })
            })
        })
    }
}

private extension Double {
    func toTimeString() -> String {
        let minutes = Int(self / kDoubleTime60)
        let seconds = Int(self) - minutes * Int(kDoubleTime60)
        return String(format: "\(minutes):%02d", seconds)
    }
}
