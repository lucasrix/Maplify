//
//  EditStoryDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class EditStoryDataSource: CSBaseTableDataSource {
    var headerView: EditStoryHeaderView! = nil
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellData = self.activeModel.cellData(indexPath)
        return EditStoryTableViewCell.contentHeight(cellData)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerView.viewHeight()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kTableViewHeaderFooterHeightMin
    }
}
