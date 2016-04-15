//
//  CSBaseTableDataSource.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

let kCellTableHeaderFooterNullHeight: CGFloat = 0.0001

@objc protocol CSBaseTableDataSourceDelegate {
    optional func didSelectModel(model: AnyObject, selection: Bool, indexPath: NSIndexPath)
    optional func willRemoveModel(model: AnyObject, indexPath: NSIndexPath)
}

class CSBaseTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var delegate: AnyObject!
    var activeModel: CSActiveModel!
    var allowMultipleSelection: Bool = false
    
    // MARK: - init
    init(tableView: UITableView, activeModel: CSActiveModel, delegate: AnyObject) {
        super.init()
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.delegate = delegate
        self.activeModel = activeModel
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.activeModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3//self.activeModel.numberOfItems(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = self.activeModel.cellData(indexPath)
        let cellIdentifier = self.activeModel.cellIdentifier(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CSTableViewCell
        cell.configure(cellData)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.canEditRow()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let cellData = self.activeModel.cellData(indexPath)
            self.delegate?.willRemoveModel?(cellData.model, indexPath: indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = self.activeModel.sectionTitle(section)
        return self.viewForHeader(section, sectionTitle: sectionTitle)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.allowMultipleSelection {
            self.provideSelectionLogic(indexPath)
        }
        
        let cellData = self.activeModel.cellData(indexPath)
        self.delegate?.didSelectModel?(cellData.model, selection: cellData.selected, indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForHeader(tableView, section: section)
    }
    
    func provideSelectionLogic(indexPath: NSIndexPath) {
        self.activeModel.provideSelection(indexPath)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    // MARK: - actions
    func removeRow(indexPath: NSIndexPath) {
        self.activeModel.removeObject(indexPath)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    func insertRows(indexPath: NSIndexPath, rowsNumber: Int, rowsAnimation: UITableViewRowAnimation) {
        var indexPathsArray = [NSIndexPath]()
        for i in 0...rowsNumber {
            let indexPathToUpdate = NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section)
            indexPathsArray.append(indexPathToUpdate)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPathsArray, withRowAnimation: rowsAnimation)
        self.tableView.endUpdates()
    }
    
    func deleteRows(indexPath: NSIndexPath, rowsNumber: Int, rowsAnimation: UITableViewRowAnimation) {
        var indexPathsArray = [NSIndexPath]()
        for i in 0...rowsNumber {
            let indexPathToUpdate = NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section)
            indexPathsArray.append(indexPathToUpdate)
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(indexPathsArray, withRowAnimation: rowsAnimation)
        self.tableView.endUpdates()
    }
    
    func selectAll() {
        self.activeModel.selectAll()
        self.tableView.reloadData()
    }
    
    func deselectAll() {
        self.activeModel.deselectAll()
        self.tableView.reloadData()
    }
    
    // MARK: - methods to override
    func canEditRow() -> Bool {
        return false
    }
    
    func viewForHeader(section: Int, sectionTitle: String!) -> UIView? {
        return nil
    }
    
    func heightForHeader(tableView: UITableView, section: Int) -> CGFloat {
        return kCellTableHeaderFooterNullHeight
    }
    
    func heightForFooter(tableView: UITableView, section: Int) -> CGFloat {
        return kCellTableHeaderFooterNullHeight
    }
}