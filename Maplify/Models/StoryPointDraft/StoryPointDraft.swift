//
//  StoryPointDraft.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/14/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos

enum DownloadState: Int {
    case Default
    case InProgress
    case Success
    case Fail
}

class StoryPointDraft: NSObject {
    var id: Int = 0
    var asset: PHAsset! = nil
    var coordinate: CLLocationCoordinate2D! = nil
    var address = String()
    var storyPointDescription = String()
    var downloadState: DownloadState = .Default
    var attachmentUrl = String()
    var storyPointKind = String()
    var storiesIds = [Int]()
    
    func readyToCreate() -> Bool {
        return (self.coordinate != nil) && (self.address.characters.count > 0)
    }
}