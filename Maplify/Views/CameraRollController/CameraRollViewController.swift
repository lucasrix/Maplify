//
//  CameraRollViewController.swift
//  CameraRoll
//
//  Created by Evgeniy Antonoff on 3/29/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import UIKit
import Photos

public enum CameraRollType: Int {
    case Photo
    case Video
}

let nibNameCameraRollView = "CameraRollView"
let nibNameAlbumViewCell = "AlbumViewCell"
let kNumberOfColumnInCollectionView: CGFloat = 4
let kItemMarginInCollectionView: CGFloat = 1
let kTime60: Double = 60
let kVideoTimeBackViewCornerRadius: CGFloat = 3

class CameraRollViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver
{
    @IBOutlet weak var imageCropView: ImageCropView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeBackView: UIView!
    
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
        
        if let view = UINib(nibName: nibNameCameraRollView, bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupCollectionView()
        self.checkPhotoAuth()
    }
    
    func setupViews() {
        self.timeBackView.layer.cornerRadius = kVideoTimeBackViewCornerRadius
    }
    
    func setupCollectionView() {
        collectionView.registerNib(UINib(nibName: nibNameAlbumViewCell, bundle: NSBundle(forClass: self.classForCoder)), forCellWithReuseIdentifier: nibNameAlbumViewCell)
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
    private func totalMarginSpace() -> CGFloat {
        return (kNumberOfColumnInCollectionView - 1) * kItemMarginInCollectionView
    }
    
    private  func cellWidth() -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.width - self.totalMarginSpace()) / kNumberOfColumnInCollectionView
    }
    
    func donePressed() {
        if self.itemDidSelect == false {
            self.delegate?.imageDidSelect(nil)
        } else if self.cameraRollType == CameraRollType.Photo {
            self.sendImage()
        } else if self.cameraRollType == CameraRollType.Video {
            self.sendVideo()
        }
    }
    
    func sendImage() {
        let view = self.imageCropView
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, -self.imageCropView.contentOffset.x, -self.imageCropView.contentOffset.y)
        view.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(image)
        self.delegate?.imageDidSelect(imageData!)
    }
    
    func sendVideo() {
        self.delegate?.videoDidSelect(self.selectedVideoData, duration: self.selectedVideoDuration)
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(nibNameAlbumViewCell, forIndexPath: indexPath) as! AlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.images[indexPath.item] as! PHAsset
        AssetRetrievingManager.retrieveImage(asset, targetSize: cellSize) { [weak self] (result, info) in
            if cell.tag == currentTag {
                cell.image = result
                cell.timeLabel.hidden = asset.mediaType != .Video
                cell.timeBackView.hidden = asset.mediaType != .Video
                if asset.mediaType == .Video {
                    let timeText = self?.durationToTimeString(asset.duration)
                    cell.timeLabel.text = timeText
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
    
    func changeItem(item: PHAsset) {
        if item.mediaType == .Video {
            self.cameraRollType = CameraRollType.Video
            changeVideo(item)
        } else {
            self.cameraRollType = CameraRollType.Photo
            changeImage(item)
            imageCropView.changeScrollable(true)
        }
    }
    
    func changeImage(asset: PHAsset) {
        self.imageCropView.image = nil
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        AssetRetrievingManager.retrieveImage(asset, targetSize: targetSize) { [weak self] (result, info) in
            self?.videoView.hidden = true
            self?.imageCropView.imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            self?.imageCropView.image = result
        }
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
        AssetRetrievingManager.retrieveVideoAsset(asset) { [weak self] (avAsset, audioMix, info) in
            let fileAsset = avAsset as? AVURLAsset
            self?.selectedVideoData = NSData(contentsOfURL: fileAsset!.URL)
            self?.selectedVideoDuration = (avAsset?.duration.seconds)!
            
            self?.videoView.hidden = false
            let timeText = self?.durationToTimeString(asset.duration)
            self?.timeLabel.text = timeText
        }
        
        // video preview
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        AssetRetrievingManager.retrieveImage(asset, targetSize: targetSize) { [weak self] (result, info) in
            self?.videoImageView.image = result
        }
    }
    
    // MARK: - Asset Caching
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
    }
}

protocol CameraRollDelegate {
    func imageDidSelect(imageData: NSData!)
    func videoDidSelect(videoData: NSData!, duration: Double)
    func cameraRollUnauthorized()
}
