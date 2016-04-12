//
//  DiscoverStoryCollectionDataSource.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDiscoverStoryDataSourceNumbersOfSection = 1
let kDiscoverStoryDataSourceStoryInfoRowNumber = 0
let kDiscoverStoryDataSourceCellsLayerWidth: CGFloat = 1
let kDiscoverStoryDataNumberOfItemsInColumnTwo = 2
let kDiscoverStoryDataNumberOfItemsInColumnThree = 3

let kDiscoverStoryDataSourceItemsCountToShowOne = 1
let kDiscoverStoryDataSourceItemsCountToShowTwo = 2
let kDiscoverStoryDataSourceItemsCountToShowThree = 3
let kDiscoverStoryDataSourceItemsCountToShowSix = 6
let kDiscoverStoryDataSourceItemsCountToShowNine = 9

class DiscoverStoryCollectionDataSource: CSBaseCollectionDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return kDiscoverStoryDataSourceNumbersOfSection
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemsCountToShow(self.activeModel.numberOfItems(section))
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = self.activeModel.cellData(indexPath)
        if indexPath.row == kDiscoverStoryDataSourceStoryInfoRowNumber {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(StoryInfoCell), forIndexPath: indexPath) as! StoryInfoCell
            cell.configure(cellData)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(StoryPointDetailCell), forIndexPath: indexPath) as! StoryPointDetailCell
            cell.configure(cellData)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.cellWidth()
        return CGSize(width: width, height: width)
    }
    
    private  func cellWidth() -> CGFloat {
        let itemsAllCount = self.activeModel.numberOfItems(0)
        let numberOfColumn = self.itemsCountToShow(itemsAllCount) == kDiscoverStoryDataNumberOfItemsInColumnTwo ? kDiscoverStoryDataNumberOfItemsInColumnTwo : kDiscoverStoryDataNumberOfItemsInColumnThree
        let totalCellsLayer: CGFloat = (CGFloat(numberOfColumn) - 1) * kDiscoverStoryDataSourceCellsLayerWidth
        return (UIScreen.mainScreen().bounds.size.width - totalCellsLayer) / CGFloat(numberOfColumn)
    }
    
    private func itemsCountToShow(itemsCount: Int) -> Int {
        switch itemsCount {
        case 1:
            return kDiscoverStoryDataSourceItemsCountToShowOne
        case 2:
            return kDiscoverStoryDataSourceItemsCountToShowTwo
        case 3, 4, 5:
            return kDiscoverStoryDataSourceItemsCountToShowThree
        case 6, 7, 8:
            return kDiscoverStoryDataSourceItemsCountToShowSix
        default:
            return kDiscoverStoryDataSourceItemsCountToShowNine
        }
    }
}
