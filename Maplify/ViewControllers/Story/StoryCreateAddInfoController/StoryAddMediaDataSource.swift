//
//  StoryAddMediaDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryAddMediaDataSource: CSBaseTableDataSource {
    var headerView: StoryAddMediaHeaderView! = nil
    
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
