//
//  DIscoverStoryPointTableDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DiscoverTableDataSource: CSBaseTableDataSource {
    var cell = DiscoverStoryCell()
    
    override init(tableView: UITableView, activeModel: CSActiveModel, delegate: AnyObject) {
        super.init(tableView: tableView, activeModel: activeModel, delegate: delegate)
        
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            self.cell = tableView.dequeueReusableCellWithIdentifier(String(DiscoverStoryCell)) as! DiscoverStoryCell
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = self.activeModel.cellData(indexPath)
        let model = cellData.model
        if model is StoryPoint {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(DiscoverStoryPointCell), forIndexPath: indexPath) as! DiscoverStoryPointCell
            cell.configure(cellData)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(DiscoverStoryCell), forIndexPath: indexPath) as! DiscoverStoryCell
            cell.configure(cellData)
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellData = self.activeModel.cellData(indexPath)
        let model = cellData.model
        var itemHeight: CGFloat = 0
        if model is StoryPoint {
            itemHeight = DiscoverStoryPointCell.contentHeightForStoryPoint(cellData)
        } else if model is Story {
            self.cell.configure(cellData)
            itemHeight = self.heightForCell(self.cell, bounds: tableView.bounds)
            itemHeight += self.cell.collectionView.contentSize.height
        }
        return itemHeight
    }
    
    func heightForCell(cell: DiscoverStoryCell, bounds: CGRect) -> CGFloat {
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), CGRectGetHeight(cell.bounds));
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let height: CGFloat = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        return height
    }

}
