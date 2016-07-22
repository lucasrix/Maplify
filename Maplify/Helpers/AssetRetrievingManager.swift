//
//  AssetRetrievingManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/15/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos

class AssetRetrievingManager {
    class func retrieveImage(asset: PHAsset, targetSize: CGSize, synchronous: Bool, completion: ((result: UIImage?, info: [NSObject : AnyObject]?) -> ())!) {
        let options = AssetRetrievingManager.defaultImageOptions(synchronous)
        PHCachingImageManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options) { (result, info) in
            completion?(result: result, info: info)
        }
    }
    
    class func retrieveVideoAsset(asset: PHAsset, completion: ((avAsset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) ->())!) {
        let options = PHVideoRequestOptions()
        options.networkAccessAllowed = false
        PHCachingImageManager().requestAVAssetForVideo(asset, options: options, resultHandler: { (avAsset, audioMix, info) -> () in
            completion?(avAsset: avAsset, audioMix: audioMix, info: info)
        })
    }
    
    class func defaultImageOptions(synchronous: Bool) -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .Opportunistic
        options.synchronous = synchronous
        options.networkAccessAllowed = false
        return options
    }
}
