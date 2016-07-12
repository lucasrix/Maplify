//
//  StoryAddMediaTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import GoogleMaps
import KMPlaceholderTextView
import UIKit

let kCellTopMargin: CGFloat = 24
let kCellLocationViewHeight: CGFloat = 39
let kCellDescriptionViewHeight: CGFloat = 73
let kLocationLabelTextColorAlphaDefault: CGFloat = 0.4

class StoryAddMediaTableViewCell: CSTableViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var changeAddressButton: UIButton!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    
    var imageManager = PHCachingImageManager()
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.setupViews()
        
        let asset = cellData.model as! PHAsset
        self.populateImage(asset)
        self.manageLocation(asset)
    }
    
    func setupViews() {
        self.imageViewHeightConstraint.constant = UIScreen().screenWidth()
        self.addressLabel.text = NSLocalizedString("Label.Loading", comment: String())
        self.changeAddressButton.setTitle(NSLocalizedString("Button.Change", comment: String()).uppercaseString, forState: .Normal)
        self.addLocationButton.setTitle(NSLocalizedString("Button.AddLocation", comment: String()).uppercaseString, forState: .Normal)
        self.descriptionTextView.placeholder = NSLocalizedString("Text.Placeholder.AddDescription", comment: String())
    }
    
    func populateImage(asset: PHAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let targetSize = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
            self.imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) { [weak self] (result, info) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self?.assetImageView.image = result
                })
            }
        })
    }
    
    func manageLocation(asset: PHAsset) {
        if asset.location != nil {
            self.retrieveLocation(asset.location!)
        } else {
            self.populateEmptyLocation()
        }
        
        let addressImageName = asset.location == nil ? CellImages.locationPink : CellImages.locationGrey
        self.addressImageView.image = UIImage(named: addressImageName)
        self.addressLabel.textColor = asset.location == nil ? UIColor.redPink() : UIColor.blackColor().colorWithAlphaComponent(kLocationLabelTextColorAlphaDefault)
        self.locationView.backgroundColor = asset.location == nil ? UIColor.redPink().colorWithAlphaComponent(0.05) : UIColor.whiteColor()
        self.changeAddressButton.hidden = asset.location == nil
        self.addLocationButton.hidden = asset.location != nil
    }
    
    func retrieveLocation(location: CLLocation) {
        GeocoderHelper.placeFromCoordinate(location.coordinate) { [weak self] (addressString) in
            self?.addressLabel.text = addressString
        }
    }
    
    func populateEmptyLocation() {
        self.addressLabel.text = NSLocalizedString("Label.LocationRequired", comment: String())
    }
    
    class func contentHeight() -> CGFloat {
        let imageViewHeight: CGFloat = UIScreen().screenWidth()
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
}
