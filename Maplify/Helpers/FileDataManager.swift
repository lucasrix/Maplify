//
//  FileDataManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/19/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class FileDataManager {
    class func fileDataForDraft(draft: StoryPointDraft, targetSize: CGSize, completion: ((fileData: NSData!, params: [String: AnyObject], kind: StoryPointKind) -> ())!) {
        if draft.asset.mediaType == .Image {
            self.imageDataForDraft(draft, targetSize: targetSize, completion: completion)
        } else if draft.asset.mediaType == .Video {
            self.videoDataForDraft(draft, completion: completion)
        }
    }
    
    private class func imageDataForDraft(draft: StoryPointDraft, targetSize: CGSize, completion: ((fileData: NSData!, params: [String: AnyObject], kind: StoryPointKind) -> ())!) {
        AssetRetrievingManager.retrieveImage(draft.asset, targetSize: targetSize, synchronous: true, completion: { (result, info) in
            var fileData: NSData! = nil
            if let image = result?.correctlyOrientedImage().cropToSquareImage().resize(targetSize) {
                fileData = UIImagePNGRepresentation(image)
            }
            let params = ["mimeType": "image/png", "fileName": "photo.png"]
            let kind = StoryPointKind.Photo
            completion?(fileData: fileData, params: params, kind: kind)
        })
    }
    
    private class func videoDataForDraft(draft: StoryPointDraft, completion: ((fileData: NSData!, params: [String: AnyObject], kind: StoryPointKind) -> ())!) {
        AssetRetrievingManager.retrieveVideoAsset(draft.asset) { (avAsset, audioMix, info) in
            let fileAsset = avAsset as? AVURLAsset
            let fileData = NSData(contentsOfURL: fileAsset!.URL)
            let params = ["mimeType": "video/quicktime", "fileName": "video.mov"]
            let kind = StoryPointKind.Video
            completion?(fileData: fileData, params: params, kind: kind)
        }
    }
}