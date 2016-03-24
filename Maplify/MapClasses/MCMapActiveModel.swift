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
}