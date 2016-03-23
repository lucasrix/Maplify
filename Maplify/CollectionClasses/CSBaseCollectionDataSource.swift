//
//  CSCollectionViewBaseDataSource.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

@objc protocol CSBaseCollectionDataSourceDelegate {
    optional func didSelectModel(model: AnyObject, indexPath: NSIndexPath)
}

class CSBaseCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var delegate: AnyObject!
    var activeModel: CSActiveModel!
    var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            self.collectionView.collectionViewLayout = self.flowLayout
        }
    }
    
    // MARK: - init
    init(collectionView: UICollectionView, activeModel: CSActiveModel, delegate: AnyObject) {
        super.init()
        self.collectionView = collectionView
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.activeModel = activeModel
        self.delegate = delegate
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.activeModel.numberOfSections()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activeModel.numberOfItems(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = self.activeModel.cellData(indexPath)
        let cellIdentifier = self.activeModel.cellIdentifier(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CSCollectionViewCell
        cell.configure(cellData)
        return cell
    }
    
    // MARK: - UITableViewDataSource
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cellData = self.activeModel.cellData(indexPath)
        self.delegate?.didSelectModel?(cellData.model, indexPath: indexPath)
    }
    
    // MARK: - Actions
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
}
