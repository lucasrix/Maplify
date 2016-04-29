//
//  ShareController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import SDWebImage
import UIKit

enum StoryPointEditContentOption: Int {
    case EditPost
    case DeletePost
    case Directions
    case SharePost
}

enum StoryPointDefaultContentOption: Int {
    case Directions
    case SharePost
    case ReportAbuse
}

enum StoryEditContentOption: Int {
    case EditStory
    case DeleteStory
    case ShareStory
}

enum StoryDefaultContentOption: Int {
    case Directions
    case ShareStory
    case ReportAbuse
}

extension UIViewController {
    
    // StoryPoint
    func showStoryPointEditContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let editPost = NSLocalizedString("Button.EditPost", comment: String())
        let deletePost = NSLocalizedString("Button.DeletePost", comment: String())
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [editPost, deletePost, directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: nil, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
        })
    }
    
    func showStoryPointDefaultContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let reportAbuse = NSLocalizedString("Button.ReportAbuse", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: reportAbuse, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
            }
        )
    }
    
    // Story
    func showEditStoryContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let editPost = NSLocalizedString("Button.EditStory", comment: String())
        let deletePost = NSLocalizedString("Button.DeleteStory", comment: String())
        let sharePost = NSLocalizedString("Button.ShareStory", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [editPost, deletePost, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: nil, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
        })
    }
    
    func showStoryDefaultContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.ShareStory", comment: String())
        let reportAbuse = NSLocalizedString("Button.ReportAbuse", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: reportAbuse, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
            }
        )
    }

    
    
    
    
    
    
    
    
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
