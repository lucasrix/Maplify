//
//  DIscoverStoryPointTableDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DiscoverTableDataSource: CSBaseTableDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellData = self.activeModel.cellData(indexPath)
        let model = cellData.model
        var itemHeight: CGFloat = 0
        if model is StoryPoint {
            itemHeight = DiscoverStoryPointCell.contentHeightForStoryPoint(cellData)
        } else if model is Story {
            // TODO:
        }
        return itemHeight
    }
}
