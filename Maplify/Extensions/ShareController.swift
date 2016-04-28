//
//  ShareController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import SDWebImage
import UIKit

extension UIViewController {
    func presentShareController(text: String!, url: NSURL!, image: UIImage!, completion: (() -> ())!) {
        var objectsToShare: [AnyObject] = []
        if (text != nil) && (text != String()){
            objectsToShare.append(text)
        }
        if url != nil {
            objectsToShare.append(url)
        }
        if image != nil {
            objectsToShare.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: completion)
    }
    
    func presentShareControllerStoryPoint(storyPointId: Int, completion: (() -> ())!) {
        let storyPoint = StoryPointManager.find(storyPointId)
        var attachmentUrl: NSURL! = nil
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            attachmentUrl = storyPoint.attachment.file_url.url
        } else {
            attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge)
        }
        let imageManager = SDWebImageManager.sharedManager()
        imageManager.downloadImageWithURL(attachmentUrl, options: .CacheMemoryOnly, progress: nil) { [weak self] (image, error, cacheType, finished, url) in
            if finished == true {
                self?.presentShareController(storyPoint.caption, url: nil, image: image, completion: completion)
            }
        }
    }
    
    func presentShareControllerStory(storyId: Int, completion: (() -> ())!) {
        let story = StoryManager.find(storyId)
        self.presentShareController(story.title, url: nil, image: nil, completion: completion)
    }
}
