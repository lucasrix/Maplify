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
    case SharePost
}

enum StoryPointDefaultContentOption: Int {
    case SharePost
    case ReportAbuse
}

enum StoryEditContentOption: Int {
    case EditStory
    case DeleteStory
    case ShareStory
}

enum StoryDefaultContentOption: Int {
    case ShareStory
    case ReportAbuse
}

extension UIViewController {
    
    // StoryPoint
    func showStoryPointEditContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let editPost = NSLocalizedString("Button.EditPost", comment: String())
        let deletePost = NSLocalizedString("Button.DeletePost", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [editPost, deletePost, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: nil, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
        })
    }
    
    func showStoryPointDefaultContentActionSheet(selectedClosure: ((selectedIndex: Int) -> ())!) {
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let reportAbuse = NSLocalizedString("Button.ReportAbuse", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [sharePost]
        
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
        let sharePost = NSLocalizedString("Button.ShareStory", comment: String())
        let reportAbuse = NSLocalizedString("Button.ReportAbuse", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: reportAbuse, buttons: buttons, handle: { (buttonIndex) in
            selectedClosure(selectedIndex: buttonIndex)
            }
        )
    }
}
