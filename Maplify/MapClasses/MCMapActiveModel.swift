//
//  MCMapActiveModel.swift
//  Maplify
//
//  Created by Sergey on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class MCMapActiveModel : CSActiveModel {
    func addItems(array: [AnyObject]) {
        var dataArray = [CSCellData]()
        
        for model in array {
            var cellData = CSCellData()
            cellData.model = model
            dataArray.append(cellData)
        }
        
        self.sectionsArray!.append(dataArray)
    }
    
    func storyPoint(indexPath: NSIndexPath) -> StoryPoint {
        let data = self.cellData(indexPath)
        return data.model as! StoryPoint
    }
    
    func storyPointIndex(location: MCMapCoordinate, section: Int) -> Int {
        let dataArray = self.sectionsArray![0]
        var i = 0
        for data in dataArray {
            let latitude = (data.model as! StoryPoint).location.latitude
            let longitude = (data.model as! StoryPoint).location.longitude
            if (latitude == location.latitude) && (longitude == location.longitude) {
                return i
            }
            i++
        }
        return NSNotFound
    }
}