//
//  DiscoverListModelManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class DiscoverListModelManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        var mutArray: [AnyObject] = []
        
        if let discoveredArray = response["discovered"] as? [AnyObject] {
            for item in discoveredArray {
                if item["type"] as! String == "StoryPoint" {
                    mutArray.append(StoryPoint(item as! [String : AnyObject]))
                } else if item["type"] as! String == "Story" {
                    mutArray.append(Story(item as! [String : AnyObject]))
                }
            }
        }
        return mutArray
    }
}
