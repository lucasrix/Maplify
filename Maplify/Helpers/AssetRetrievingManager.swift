//
//  AssetRetrievingManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/15/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos

class AssetRetrievingManager {
    class func retrieveImage(asset: PHAsset, targetSize: CGSize, completion: ((result: UIImage?, info: [NSObject : AnyObject]?) -> ())!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            PHCachingImageManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) { (result, info) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion?(result: result, info: info)
                })
            }
        })
    }
    
    class func retrieveVideoAsset(asset: PHAsset, completion: ((avAsset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) ->())!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let options = PHVideoRequestOptions()
            options.networkAccessAllowed = true
            PHCachingImageManager().requestAVAssetForVideo(asset, options: options, resultHandler: { (avAsset, audioMix, info) -> () in
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion?(avAsset: avAsset, audioMix: audioMix, info: info)
                })
            })
        })
    }
}
