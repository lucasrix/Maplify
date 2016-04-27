//
//  StoryEditTableDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryEditTableDataSource: CSBaseTableDataSource {
    var storyEditDelegate: StoryEditDataSourceDelegate! = nil
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "X\nRemove post") { [weak self] (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            
            self?.storyEditDelegate?.didRemoveItem(indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    override func canEditRow() -> Bool {
        return true
    }   
}

protocol StoryEditDataSourceDelegate {
    func didRemoveItem(indexPath: NSIndexPath)
}
