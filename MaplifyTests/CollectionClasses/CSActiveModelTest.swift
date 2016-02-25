//
//  MaplifyTests.swift
//  MaplifyTests
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import XCTest
@testable import Maplify

class CSActiveModelTest: XCTestCase {
    var activeModel: CSActiveModel! = nil
    
    override func setUp() {
        super.setUp()
        
        self.activeModel = CSActiveModel()
    }
    
    // MARK: - test init
    func testSectionsArray() {
        XCTAssertNotNil(self.activeModel.sectionsArray)
    }
    
    // MARK: - test data items
    func testAddItem() {
        self.activeModel.addItem("row 0", section: 0, cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        XCTAssertEqual(self.activeModel.numberOfSections(), 1)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 1)
    }
    
    func testAddItemToUnexistingSection() {
        self.activeModel.addItem("row 0", section: 4, cellIdentifier: "cellId", sectionTitle: "fourth section", delegate: nil)
        XCTAssertEqual(self.activeModel.numberOfSections(), 5)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 0)
        XCTAssertEqual(self.activeModel.numberOfItems(4), 1)
    }
    
    func testAddItems() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        XCTAssertEqual(self.activeModel.numberOfSections(), 1)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 2)
    }
    
    func testAddMultipleItems() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItem("row 2", section: 0, cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        XCTAssertEqual(self.activeModel.numberOfSections(), 1)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 3)
        
        self.activeModel.addItem("row 0", section: 3, cellIdentifier: "cellId", sectionTitle: "third section", delegate: nil)
        XCTAssertEqual(self.activeModel.numberOfSections(), 4)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 3)
        XCTAssertEqual(self.activeModel.numberOfItems(3), 1)
    }
    
    func testInsertItems() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.insertItems(["row A", "row B"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil, indexPath: NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertEqual(self.activeModel.numberOfSections(), 1)
        XCTAssertEqual(self.activeModel.numberOfItems(0), 4)
    }
    
    func testInsertItemsToUnexistingSection() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.insertItems(["row A", "row B", "row C"], cellIdentifier: "cellId", sectionTitle: "some section", delegate: nil, indexPath: NSIndexPath(forRow: 0, inSection: 3))
        XCTAssertEqual(self.activeModel.numberOfSections(), 4)
        XCTAssertEqual(self.activeModel.numberOfItems(3), 3)
    }
    
    // MARK: - test delete items
    func testDeleteItems() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "cellId", sectionTitle: "first section", delegate: nil)
        self.activeModel.deleteItems(NSIndexPath(forRow: 1, inSection: 1), itemsCount: 2)
        XCTAssertEqual(self.activeModel.numberOfItems(1), 2)
    }
    
    func testRemoveData() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "cellId", sectionTitle: "first section", delegate: nil)
        self.activeModel.removeData()
        XCTAssertEqual(self.activeModel.numberOfSections(), 0)
    }
    
    func testRemoveObject() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "cellId", sectionTitle: "first section", delegate: nil)
        self.activeModel.removeObject(NSIndexPath(forRow: 3, inSection: 1))
        XCTAssertEqual(self.activeModel.numberOfItems(1), 3)
    }
    
    // MARK: - test data source
    func testCellId() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "firstCellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "secondCellId", sectionTitle: "first section", delegate: nil)
        XCTAssertEqual(self.activeModel.cellIdentifier(NSIndexPath(forRow: 0, inSection: 0)), "firstCellId")
        XCTAssertEqual(self.activeModel.cellIdentifier(NSIndexPath(forRow: 3, inSection: 1)), "secondCellId")
    }
    
    func testSectionTitle() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "firstCellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "secondCellId", sectionTitle: "first section", delegate: nil)
        XCTAssertEqual(self.activeModel.sectionTitle(1), "first section")
    }
    
    func testCellData() {
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "cellId", sectionTitle: "zero section", delegate: self)
        let cellData = self.activeModel.cellData(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertNotNil(cellData)
        XCTAssertEqual(cellData.model as? String, "row B")
        XCTAssertEqual(cellData.selected, false)
        XCTAssertEqual(cellData.cellIdentifier, "cellId")
        XCTAssertEqual(cellData.sectionTitle, "zero section")
        XCTAssertEqual(cellData.delegate as? CSActiveModelTest, self)
    }
    
    // MARK: - test selection
    func testSelectModel() {
        self.activeModel.addItems(["row 0", "row 1"], cellIdentifier: "firstCellId", sectionTitle: "zero section", delegate: nil)
        self.activeModel.addItems(["row A", "row B", "row C", "row D"], cellIdentifier: "secondCellId", sectionTitle: "first section", delegate: nil)
        self.activeModel.selectModel(NSIndexPath(forRow: 1, inSection: 0), selected: true)
        XCTAssertEqual(self.activeModel.selectedIndexPathes().count, 1)
        XCTAssertEqual(self.activeModel.selectedIndexPathes().first, NSIndexPath(forRow: 1, inSection: 0))
    }
}
