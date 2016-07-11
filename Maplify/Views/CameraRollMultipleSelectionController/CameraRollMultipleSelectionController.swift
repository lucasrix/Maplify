//
//  CameraRollMultipleSelectionController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import Photos

let nibNameCameraRollMultipleSelectionView = "CameraRollMultipleSelectionView"
let nibNameCameraRollItemViewCell = "CameraRollItemViewCell"
let kMaxItemsCount: Int = 10

protocol CameraRollMultipleSelectionDelegate {
    func cameraRollUnauthorized()
}

class CameraRollMultipleSelectionController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedItemsCountLabel: UILabel!
    
    var images: PHFetchResult!
    var imageManager: PHCachingImageManager?
    var cellSize: CGSize = CGSizeZero
    var delegate: CameraRollMultipleSelectionDelegate! = nil
    var selectedIndexes = [Int]()
    var selectedAssets = [PHAsset]()
    var maxItemsCount = kMaxItemsCount

    // MARK: - view controller life cycle
    override func loadView() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: nibNameCameraRollMultipleSelectionView, bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupCollectionView()
        self.checkPhotoAuth()
        self.selectedItemsCountLabel.text = String(format: NSLocalizedString("Label.CameraRollAddUpCount", comment: String()), self.maxItemsCount)
    }
    
    func setupCollectionView() {
        collectionView.registerNib(UINib(nibName: nibNameCameraRollItemViewCell, bundle: NSBundle(forClass: self.classForCoder)), forCellWithReuseIdentifier: nibNameCameraRollItemViewCell)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let cellWidth: CGFloat = self.cellWidth()
        self.cellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setupImages() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.images = PHAsset.fetchAssetsWithOptions(options)
        collectionView.reloadData()
    }
    
    func populateSelectedItemsCountLabel() {
        self.selectedItemsCountLabel.text = String(format: NSLocalizedString("Label.CameraRollSelectedOfCount", comment: String()), self.selectedAssets.count, self.maxItemsCount)
    }
    
    // MARK: - private
    private  func cellWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width / kNumberOfColumnInCollectionView
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(nibNameCameraRollItemViewCell, forIndexPath: indexPath) as! CameraRollItemViewCell
        let asset = self.images[indexPath.item] as! PHAsset
        let selected = self.selectedIndexes.contains(indexPath.row)
        cell.configure(asset, targetSize: self.cellSize, selected: selected)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images == nil ? 0 : self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.cellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.selectedIndexes.contains(indexPath.row) {
            let index = self.selectedIndexes.indexOf(indexPath.row)
            self.selectedIndexes.removeAtIndex(index!)
            self.selectedAssets.removeAtIndex(index!)
        } else {
            self.selectedIndexes.append(indexPath.row)
            self.selectedAssets.append(self.images.objectAtIndex(indexPath.row) as! PHAsset)
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CameraRollItemViewCell
        cell.updateSelection(self.selectedIndexes.contains(indexPath.row))
        
        self.populateSelectedItemsCountLabel()
    }
    
    //MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue()) {
            let collectionChanges = changeInstance.changeDetailsForFetchResult(self.images)
            if collectionChanges != nil {
                self.images = collectionChanges!.fetchResultAfterChanges
                let collectionView = self.collectionView!
                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
                    collectionView.reloadData()
                } else {
                    collectionView.performBatchUpdates({
                        let removedIndexes = collectionChanges!.removedIndexes
                        if (removedIndexes?.count ?? 0) != 0 {
                            collectionView.deleteItemsAtIndexPaths(removedIndexes!.indexPathsFromIndexesWithSection(0))
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItemsAtIndexPaths(insertedIndexes!.indexPathsFromIndexesWithSection(0))
                        }
                        let changedIndexes = collectionChanges!.changedIndexes
                        if (changedIndexes?.count ?? 0) != 0 {
                            collectionView.reloadItemsAtIndexPaths(changedIndexes!.indexPathsFromIndexesWithSection(0))
                        }
                    }, completion: nil)
                }
                self.resetCachedAssets()
            }
        }
    }
}

internal extension NSIndexSet {
    func indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerateIndexesUsingBlock {idx, stop in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
    }
}

private extension CameraRollMultipleSelectionController {
    // Check the status of authorization for PHPhotoLibrary
    private func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> () in
                switch status {
                    
                case .Authorized:
                    self?.imageManager = PHCachingImageManager()
                    self?.setupImages()
                    
                case .Restricted, .Denied:
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?.delegate?.cameraRollUnauthorized()
                    })
                    
                default:
                    break
                }
            })
        }
    }
    
    // MARK: - Asset Caching
    func resetCachedAssets() {
        self.imageManager?.stopCachingImagesForAllAssets()
    }
}
