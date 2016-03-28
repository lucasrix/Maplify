//
//  StoryPointDataSource.swift
//  Maplify
//
//  Created by Sergey on 3/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class StoryPointDataSource: CSBaseCollectionDataSource {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, collectionView.bounds.height)
    }
}