//
//  CameraRollViewController.swift
//  CameraRoll
//
//  Created by Evgeniy Antonoff on 3/29/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import UIKit
import Photos

let nibNameCameraRollView = "CameraRollView"
let nibNameAlbumViewCell = "AlbumViewCell"

class CameraRollViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver
{
    @IBOutlet weak var imageCropView: ImageCropView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: PHFetchResult!
    var imageManager: PHCachingImageManager?
    var previousPreheatRect: CGRect = CGRectZero
    var cellSize: CGSize = CGSizeZero
    var delegate: CameraRollDelegate! = nil
    
    override func loadView() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: nibNameCameraRollView, bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.setupCollectionView()
        self.checkPhotoAuth()
        self.setupImages()
    }
    
    func setupCollectionView() {
        collectionView.registerNib(UINib(nibName: nibNameAlbumViewCell, bundle: NSBundle(forClass: self.classForCoder)), forCellWithReuseIdentifier: nibNameAlbumViewCell)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width - 3) / 4
        self.cellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setupImages() {
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        images = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        if images.count > 0 {
            changeImage(images[0] as! PHAsset)
        }
        collectionView.reloadData()
    }
    
    func donePressed() {
        let view = self.imageCropView
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -self.imageCropView.contentOffset.x, -self.imageCropView.contentOffset.y)
        view.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        delegate?.imageDidSelect(image)
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(nibNameAlbumViewCell, forIndexPath: indexPath) as! AlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.images[indexPath.item] as! PHAsset
        self.imageManager?.requestImageForAsset(asset,
                                                targetSize: cellSize,
                                                contentMode: .AspectFill,
                                                options: nil) {
                                                    result, info in
                                                    
                                                    if cell.tag == currentTag {
                                                        cell.image = result
                                                    }
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        changeImage(images[indexPath.row] as! PHAsset)
        imageCropView.changeScrollable(true)
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
                            collectionView.deleteItemsAtIndexPaths(removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItemsAtIndexPaths(insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let changedIndexes = collectionChanges!.changedIndexes
                        if (changedIndexes?.count ?? 0) != 0 {
                            collectionView.reloadItemsAtIndexPaths(changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        }, completion: nil)
                }
                self.resetCachedAssets()
            }
        }
    }
}

internal extension UICollectionView {
    
    func aapl_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
}

internal extension NSIndexSet {
    func aapl_indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerateIndexesUsingBlock {idx, stop in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
    }
}

private extension CameraRollViewController {
    func changeImage(asset: PHAsset) {
        self.imageCropView.image = nil
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let options = PHImageRequestOptions()
            options.networkAccessAllowed = true
            
            self.imageManager?.requestImageForAsset(asset,
                targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                contentMode: .AspectFill,
            options: options) {
                result, info in
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageCropView.imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                    self.imageCropView.image = result
                })
            }
        })
    }
    
    // Check the status of authorization for PHPhotoLibrary
    private func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .Authorized:
                self.imageManager = PHCachingImageManager()
                if self.images != nil && self.images.count > 0 {
                    self.changeImage(self.images[0] as! PHAsset)
                }
                
            case .Restricted, .Denied:
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.cameraRollUnauthorized()
                })
                
            default:
                break
            }
        }
    }
    
    // MARK: - Asset Caching
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRectZero
    }
    
    func updateCachedAssets() {
        var preheatRect = self.collectionView!.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect))
        if delta > CGRectGetHeight(self.collectionView!.bounds) / 3.0 {
            
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            self.computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: {removedRect in
                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(removedRect)
                removedIndexPaths += indexPaths
                }, addedHandler: {addedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.imageManager?.startCachingImagesForAssets(assetsToStartCaching,
                                                           targetSize: cellSize,
                                                           contentMode: .AspectFill,
                                                           options: nil)
            self.imageManager?.stopCachingImagesForAssets(assetsToStopCaching,
                                                          targetSize: cellSize,
                                                          contentMode: .AspectFill,
                                                          options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: CGRect->Void, addedHandler: CGRect->Void) {
        if CGRectIntersectsRect(newRect, oldRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            if newMaxY > oldMaxY {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            let asset = self.images[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        return assets
    }
}

protocol CameraRollDelegate {
    func imageDidSelect(image: UIImage)
    func cameraRollUnauthorized()
}
