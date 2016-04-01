//
//  ActiveModel.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import Foundation

class CSActiveModel {
    var sectionsArray: [[CSCellData]]?
    var page: Int = 1
    
    // MARK: - Init
    init() {
        self.sectionsArray = [[CSCellData]]()
    }
    
    // MARK: - Add items
    func addItem(model: AnyObject, section: Int, cellIdentifier: String, sectionTitle: String, delegate: AnyObject!) {
        if section >= self.sectionsArray?.count {
            for _ in (self.sectionsArray?.count)!...section {
                self.sectionsArray?.append([CSCellData]())
            }
        }
        
        var array = self.sectionsArray?[section]
        
        var cellData = CSCellData()
        cellData.model = model
        cellData.cellIdentifier = cellIdentifier
        cellData.sectionTitle = sectionTitle
        cellData.delegate = delegate
        
        array?.append(cellData)
        
        self.sectionsArray?[section] = array!
    }
    
    func addItems(array: [AnyObject], cellIdentifier: String, sectionTitle: String!, delegate: AnyObject!) {
        var dataArray = [CSCellData]()
        
        for model in array {
            var cellData = CSCellData()
            cellData.model = model
            cellData.cellIdentifier = cellIdentifier
            cellData.sectionTitle = sectionTitle
            cellData.delegate = delegate
            dataArray.append(cellData)
        }
        
        self.sectionsArray!.append(dataArray)
    }
    
    func insertItems(array: [AnyObject], cellIdentifier: String, sectionTitle: String,
        delegate: AnyObject!, indexPath: NSIndexPath) {
            if indexPath.section > self.sectionsArray?.count {
                for _ in (self.sectionsArray?.count)!...indexPath.section {
                    self.sectionsArray?.append([CSCellData]())
                }
            }
            
            var dataArray = self.sectionsArray![indexPath.section]
            
            var rowCount = 0
            for item in array {
                var cellData = CSCellData()
                cellData.model = item
                cellData.cellIdentifier = cellIdentifier
                cellData.sectionTitle = sectionTitle
                cellData.delegate = delegate
                
                dataArray.insert(cellData, atIndex: indexPath.row + rowCount)
                rowCount += 1
            }
            
            self.sectionsArray![indexPath.section] = dataArray
    }
    
    // MARK: - Remove items
    func deleteItems(indexPath: NSIndexPath, itemsCount: Int) {
        if self.sectionsArray?.count > 0 {
            var dataArray = self.sectionsArray![indexPath.section]
            let range = NSMakeRange(indexPath.row, itemsCount)
            let indexSet = NSIndexSet(indexesInRange: range)
            if dataArray.count >= range.location + range.length {
                dataArray.removeAtIndexes(indexSet.toArray())
            }
            self.sectionsArray![indexPath.section] = dataArray
        }
    }
    
    func removeData() {
        for var dataArray in self.sectionsArray! {
            dataArray.removeAll()
        }
        self.sectionsArray?.removeAll()
    }
    
    func removeObject(indexPath: NSIndexPath) {
        self.sectionsArray![indexPath.section].removeAtIndex(indexPath.row)
    }
    
    // MARK: - data source
    func numberOfSections() -> Int {
        return (self.sectionsArray?.count)!
    }
    
    func numberOfItems(section: Int) -> Int {
        return (self.numberOfSections() > section) ? (self.sectionsArray?[section].count)! : 0
    }
    
    func cellData(indexPath: NSIndexPath) -> CSCellData {
        return self.sectionsArray![indexPath.section][indexPath.row]
    }
    
    func cellIdentifier(indexPath: NSIndexPath) -> String {
        return self.sectionsArray![indexPath.section][indexPath.row].cellIdentifier
    }
    
    func sectionTitle(section: Int) -> String! {
        return self.sectionsArray![section].last?.sectionTitle
    }
    
    // MARK: - selection
    func selectModel(indexPath: NSIndexPath, selected: Bool) {
        self.sectionsArray![indexPath.section][indexPath.row].selected = selected
    }
    
    func selectModels(selectedIndexPathes: [NSIndexPath]) {
        for indexPath in selectedIndexPathes {
            self.selectModel(indexPath, selected: true)
        }
    }
    
    func selectedModels() -> [CSCellData] {
        var array = [CSCellData]()
        for dataArray in self.sectionsArray! {
            for cellData in dataArray {
                if cellData.selected {
                    array.append(cellData)
                }
            }
        }
        return array
    }
    
    func selectAll() {
        self.performSelection(true)
    }
    
    func deselectAll() {
        self.performSelection(false)
    }
    
    private func performSelection(selection: Bool) {
        for dataArray in self.sectionsArray! {
            for var cellData in dataArray {
                cellData.selected = true
            }
        }
    }
    
    func selectedIndexPathes() -> [NSIndexPath] {
        var array = [NSIndexPath]()
        var row = 0
        var section = 0
        for dataArray in self.sectionsArray! {
            for cellData in dataArray {
                if cellData.selected {
                    array.append(NSIndexPath(forRow: row, inSection: section))
                }
                row += 1
            }
            section += 1
        }
        return array
    }
    
    func provideSelection(indexPath: NSIndexPath) {
        var cellData = self.sectionsArray![indexPath.section][indexPath.row]
        cellData.selected = !cellData.selected
    }
    
    // MARK: - helper methods
    func hasData() -> Bool {
        return (self.sectionsArray?.count > 0)
    }
    
    func indexPathOfModel(model: AnyObject) -> NSIndexPath {
        var indexPath = NSIndexPath()
        var row = 0
        var section = 0
        for dataArray in self.sectionsArray! {
            for cellData in dataArray {
                if cellData.model === model {
                    indexPath = NSIndexPath(forRow: row, inSection: section)
                }
                row += 1
            }
            section += 1
        }
        return indexPath
    }
    
    func updatePage() {
        self.page += 1
    }
}

extension Array {
    mutating func removeAtIndexes(indexes: [Int]) {
        indexes.sort(>).forEach { removeAtIndex($0) }
    }
}

extension NSIndexSet {
    func toArray() -> [Int] {
        var indexes:[Int] = [];
        self.enumerateIndexesUsingBlock { (index:Int, _) in
            indexes.append(index);
        }
        return indexes;
    }
}