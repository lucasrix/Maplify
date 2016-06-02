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
            let cellData = CSCellData()
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
        for i in 0...dataArray.count {
            let data = dataArray[i]
            if data.model is StoryPoint {
                let latitude = (data.model as! StoryPoint).location.latitude
                let longitude = (data.model as! StoryPoint).location.longitude
                if (latitude == location.latitude) && (longitude == location.longitude) {
                    return i
                }
            }
        }
        return NSNotFound
    }
    
    func selectPinAtIndex(index: Int) {
        if index != NSNotFound {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let cellData = self.cellData(indexPath)
            self.deselectAll()
            cellData?.selected = !(cellData?.selected)!
        }
    }
}