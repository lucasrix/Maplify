//
//  DIscoverStoryPointTableDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DiscoverTableDataSource: CSBaseTableDataSource {
    var storyCell = DiscoverStoryCell()
    var storyPointCell = DiscoverStoryPointCell()
    
    override init(tableView: UITableView, activeModel: CSActiveModel, delegate: AnyObject) {
        super.init(tableView: tableView, activeModel: activeModel, delegate: delegate)
        
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            self.storyCell = tableView.dequeueReusableCellWithIdentifier(String(DiscoverStoryCell)) as! DiscoverStoryCell
            self.storyPointCell = tableView.dequeueReusableCellWithIdentifier(String(DiscoverStoryPointCell)) as! DiscoverStoryPointCell
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
            self.storyPointCell.configure(cellData)
            itemHeight = self.heightForCell(self.storyPointCell, bounds: tableView.bounds)
        } else if model is Story {
            self.storyCell.configure(cellData)
            itemHeight = self.heightForCell(self.storyCell, bounds: tableView.bounds)
            itemHeight += self.storyCell.collectionView.contentSize.height
        }
        return itemHeight
    }
    
    func heightForCell(cell: CSTableViewCell, bounds: CGRect) -> CGFloat {
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), CGRectGetHeight(cell.bounds));
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let height: CGFloat = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        return height
    }

}
