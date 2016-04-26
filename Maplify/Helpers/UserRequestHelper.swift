//
//  UserRequestHelper.swift
//  Maplify
//
//  Created by Sergei on 26/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class UserRequestHelper {
    class func retrieveUserData(userId: Int, success: successClosure!, failure: failureClosure!) {
        ApiClient.sharedClient.getUserStoryPoints(userId,
            success: { (response) in
                let storyPoints = response as! [StoryPoint]
                ApiClient.sharedClient.getUserStories(userId, success: { (response) in
                    let stories = response as! [Story]
                    let mergedArray = UserRequestHelper.sortAndMerge(storyPoints, stories: stories)
                    success(response: mergedArray)
                    }, failure: failure)
            },
            failure: failure)
    }
    
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