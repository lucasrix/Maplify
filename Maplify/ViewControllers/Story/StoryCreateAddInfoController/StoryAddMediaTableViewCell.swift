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
let kEmptyLocationViewAlpha: CGFloat = 0.05

protocol StoryAddMediaTableViewCellDelegate {
    func getIndexOfObject(draft: StoryPointDraft, completion: ((index: Int, count: Int) -> ())!)
    func addLocationDidTap(completion: ((location: CLLocationCoordinate2D, address: String) -> ())!)
}

class StoryAddMediaTableViewCell: CSTableViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var changeAddressButton: UIButton!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var orderBackView: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var isVideoImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    
    var imageManager = PHCachingImageManager()
    var delegate: StoryAddMediaTableViewCellDelegate! = nil
    var draft: StoryPointDraft! = nil
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let draft = cellData.model as! StoryPointDraft
        self.draft = draft
        self.delegate = cellData.delegate as! StoryAddMediaTableViewCellDelegate
        self.setupViews()
        self.populateOrder()
        self.manageImage()
        self.manageLocation()
    }
    
    func setupViews() {
        let asset = self.draft?.asset
        self.imageViewHeightConstraint?.constant = UIScreen().screenWidth()
        let orderBackViewCornerRadius = CGRectGetHeight(self.orderBackView.frame) / 2
        self.orderBackView?.layer.cornerRadius = orderBackViewCornerRadius
        self.isVideoImageView?.hidden = asset?.mediaType == .Image
        self.cropButton?.hidden = asset?.mediaType == .Video
        self.addressLabel?.text = NSLocalizedString("Label.Loading", comment: String())
        self.changeAddressButton?.setTitle(NSLocalizedString("Button.Change", comment: String()).uppercaseString, forState: .Normal)
        self.addLocationButton?.setTitle(NSLocalizedString("Button.AddLocation", comment: String()).uppercaseString, forState: .Normal)
        self.descriptionTextView?.placeholder = NSLocalizedString("Text.Placeholder.AddDescription", comment: String())
    }
    
    func populateOrder() {
        self.delegate?.getIndexOfObject(draft, completion: { [weak self] (index, count) in
            let order = index + 1
            self?.orderLabel?.text = String(format: NSLocalizedString("Label.StoryAddInfoPostsOrder", comment: String()), order, count)
        })
    }
    
    func manageImage() {
        if self.draft?.image != nil {
            self.populateImage()
        } else {
            self.retrieveImage()
        }
    }
    
    func populateImage() {
        self.assetImageView?.image = self.draft?.image
    }
    
    func retrieveImage() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let targetSize = CGSizeMake(CGFloat(self.draft.asset.pixelWidth), CGFloat(self.draft.asset.pixelHeight))
            self.imageManager.requestImageForAsset(self.draft.asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) { [weak self] (result, info) in
                self?.draft?.image = result!
                
                dispatch_async(dispatch_get_main_queue(), {
                    self?.populateImage()
                })
            }
        })
    }
    
    func manageLocation() {
        if self.draft?.coordinate != nil {
            self.retrieveLocationIfNeeded()
        } else {
            self.populateEmptyLocation()
        }
    }
    
    func retrieveLocationIfNeeded() {
        if self.draft?.address.characters.count > 0 {
            self.populateLocation()
        } else {
            GeocoderHelper.placeFromCoordinate(draft.coordinate) { [weak self] (addressString) in
                self?.draft?.address = addressString
                self?.populateLocation()
            }
        }
    }
    
    func populateLocation() {
        let address = self.draft?.address
        self.addressLabel.text = address
        self.addressImageView.image = UIImage(named: CellImages.locationGrey)
        self.addressLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(kLocationLabelTextColorAlphaDefault)
        self.locationView.backgroundColor = UIColor.whiteColor()
        self.changeAddressButton.hidden = false
        self.addLocationButton.hidden = true
    }
    
    func populateEmptyLocation() {
        self.addressLabel.text = NSLocalizedString("Label.LocationRequired", comment: String())
        self.addressImageView.image = UIImage(named: CellImages.locationPink)
        self.addressLabel.textColor = UIColor.redPink()
        self.locationView.backgroundColor = UIColor.redPink().colorWithAlphaComponent(kEmptyLocationViewAlpha)
        self.changeAddressButton.hidden = true
        self.addLocationButton.hidden = false
    }
    
    // MARK: - actions
    @IBAction func addLocationTapped(sender: UIButton) {
        self.delegate?.addLocationDidTap({ [weak self] (location, address) in
            self?.draft?.address = address
            self?.draft?.coordinate = location
            self?.populateLocation()
        })
    }
    
    @IBAction func changeLocationTapped(sender: UIButton) {
        self.delegate?.addLocationDidTap({ [weak self] (location, address) in
            self?.draft?.address = address
            self?.draft?.coordinate = location
            self?.populateLocation()
        })
    }
    
    class func contentHeight() -> CGFloat {
        let imageViewHeight: CGFloat = UIScreen().screenWidth()
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
}
