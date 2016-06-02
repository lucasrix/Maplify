//
//  DetailStoryItemsDataSource.swift
//  Maplify
//
//  Created by Sergei on 30/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class DetailStoryItemsDataSource: CSBaseCollectionDataSource {
    var boundingSize: CGSize = CGSizeZero
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return kDiscoverStoryDataSourceNumbersOfSection
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DiscoverStoryCell.itemsCountToShow(self.activeModel.numberOfItems(section)).0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = self.activeModel.cellData(indexPath)
        
        if indexPath.row == kDiscoverStoryDataSourceStoryInfoRowNumber {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(DetailStoryNumberCell), forIndexPath: indexPath) as! DetailStoryNumberCell
            cell.configure(cellData)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(DetailStoryPointCollectionCell), forIndexPath: indexPath) as! DetailStoryPointCollectionCell
            cell.configure(cellData)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellData = self.activeModel.cellData(indexPath)
        self.boundingSize = cellData.boundingSize

        let width = self.cellWidth()
        return CGSize(width: width, height: width)
    }
    
    func cellWidth() -> CGFloat {
        let itemsAllCount = self.activeModel.numberOfItems(0)
        let numberOfColumn = DiscoverStoryCell.itemsCountToShow(itemsAllCount).0 == kDiscoverStoryDataNumberOfItemsInColumnTwo ? kDiscoverStoryDataNumberOfItemsInColumnTwo : kDiscoverStoryDataNumberOfItemsInColumnThree
        let totalCellsLayer: CGFloat = (CGFloat(numberOfColumn) - 1) * kDiscoverStoryDataSourceCellsLayerWidth
        return (self.boundingSize.width - totalCellsLayer) / CGFloat(numberOfColumn)
    }
}