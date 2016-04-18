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

class DiscoverStoryCollectionDataSource: CSBaseCollectionDataSource {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return kDiscoverStoryDataSourceNumbersOfSection
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DiscoverStoryCell.itemsCountToShow(self.activeModel.numberOfItems(section)).0
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
        let numberOfColumn = DiscoverStoryCell.itemsCountToShow(itemsAllCount).0 == kDiscoverStoryDataNumberOfItemsInColumnTwo ? kDiscoverStoryDataNumberOfItemsInColumnTwo : kDiscoverStoryDataNumberOfItemsInColumnThree
        let totalCellsLayer: CGFloat = (CGFloat(numberOfColumn) - 1) * kDiscoverStoryDataSourceCellsLayerWidth
        return (UIScreen.mainScreen().bounds.size.width - totalCellsLayer) / CGFloat(numberOfColumn)
    }
}
