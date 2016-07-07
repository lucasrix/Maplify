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

class CameraRollMultipleSelectionController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: PHFetchResult!
    var imageManager: PHCachingImageManager?
    var cellSize: CGSize = CGSizeZero
    var delegate: CameraRollDelegate! = nil
    var cameraRollType: CameraRollType = CameraRollType.Photo
    var selectedVideoData: NSData! = nil
    var selectedVideoDuration: Double = 0
    var itemDidSelect: Bool = false

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
    }
    
    func setupCollectionView() {
        collectionView.registerNib(UINib(nibName: nibNameCameraRollItemViewCell, bundle: NSBundle(forClass: self.classForCoder)), forCellWithReuseIdentifier: nibNameCameraRollItemViewCell)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let cellWidth: CGFloat = self.cellWidth()
        self.cellSize = CGSizeMake(cellWidth, cellWidth)
    }
    
    func setupImages() {
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        images = PHAsset.fetchAssetsWithOptions(options)
        if images.count > 0 {
            changeItem(images[0] as! PHAsset)
        }
        collectionView.reloadData()
    }
    
    // MARK: - private
    private  func cellWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width / kNumberOfColumnInCollectionView
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(nibNameCameraRollItemViewCell, forIndexPath: indexPath) as! CameraRollItemViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.images[indexPath.item] as! PHAsset
        self.imageManager?.requestImageForAsset(asset, targetSize: cellSize, contentMode: .AspectFill, options: nil) { [weak self] (result, info) in
            
            if cell.tag == currentTag {
                cell.image = result
//                cell.timeLabel.hidden = asset.mediaType != .Video
                if asset.mediaType == .Video {
                    let timeText = self?.durationToTimeString(asset.duration)
//                    cell.timeLabel.text = timeText
                }
            }
        }
        return cell
    }
    
    func durationToTimeString(duration: NSTimeInterval) -> String {
        let minutes = Int(duration / kTime60)
        let minutesString = String("\(minutes)")
        let seconds = Int(duration) - minutes * Int(kTime60)
        let secondsString = seconds >= 10 ? String(":\(seconds)") : String(":0\(seconds)")
        return minutesString + secondsString
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.cellWidth()
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.itemDidSelect = true
        let item = images[indexPath.row] as! PHAsset
        self.changeItem(item)
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
    
    func changeItem(item: PHAsset) {
        if item.mediaType == .Video {
            self.cameraRollType = CameraRollType.Video
            changeVideo(item)
        } else {
            self.cameraRollType = CameraRollType.Photo
            changeImage(item)
        }
    }
    
    func changeImage(asset: PHAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let options = PHImageRequestOptions()
            options.networkAccessAllowed = true
            
            self.imageManager?.requestImageForAsset(asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .AspectFill, options: options) { [weak self] (result, info) in
                // TODO:
            }
        })
    }
    
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
    
    private func changeVideo(asset: PHAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let options = PHVideoRequestOptions()
            options.networkAccessAllowed = true
            
            self.imageManager?.requestAVAssetForVideo(asset, options: options, resultHandler: { [weak self] (avAsset, audioMix, info) -> () in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let fileAsset = avAsset as? AVURLAsset
                    self?.selectedVideoData = NSData(contentsOfURL: fileAsset!.URL)
                    self?.selectedVideoDuration = (avAsset?.duration.seconds)!
                        // TODO:
                })
            })
            
            // video preview
            let imageOptions = PHImageRequestOptions()
            self.imageManager?.requestImageForAsset(asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .AspectFill, options: imageOptions) { [weak self] (result, info) in
                // TODO:
            }
        })
    }
    
    // MARK: - Asset Caching
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
    }
}
