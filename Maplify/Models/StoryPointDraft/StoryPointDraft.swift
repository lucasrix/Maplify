//
//  StoryPointDraft.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/14/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos

class StoryPointDraft: NSObject {
    var asset: PHAsset! = nil
    var coordinate: CLLocationCoordinate2D! = nil
    var address = String()
    var storyPointdescription = String()
    var image: UIImage! = nil
}