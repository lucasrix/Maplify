//
//  UserRequestHelper.swift
//  Maplify
//
//  Created by Sergei on 26/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class UserRequestResponseHelper {
    class func sortAndMerge(storyPoints: [StoryPoint], stories: [Story]) -> [AnyObject]! {
        var mergedArray = [AnyObject]()
        for storyPoint in storyPoints {
            mergedArray.append(storyPoint)
        }
        
        for story in stories {
            mergedArray.append(story)
        }
        
        return mergedArray.sort({ ($0 as! Model).created_at.compare(($1 as! Model).created_at) == NSComparisonResult.OrderedDescending })
    }
}