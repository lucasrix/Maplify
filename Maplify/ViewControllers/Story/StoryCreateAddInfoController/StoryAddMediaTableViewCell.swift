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
import MBProgressHUD
import UIKit

let kCellTopMargin: CGFloat = 24
let kCellLocationViewHeight: CGFloat = 39
let kCellDescriptionViewHeight: CGFloat = 73
let kLocationLabelTextColorAlphaDefault: CGFloat = 0.4
let kEmptyLocationViewAlpha: CGFloat = 0.05

protocol StoryAddMediaTableViewCellDelegate {
    func getIndexOfObject(draft: StoryPointDraft, completion: ((index: Int, count: Int) -> ())!)
    func addLocationDidTap(completion: ((location: CLLocationCoordinate2D, address: String) -> ())!)
    func retryPostStoryPointDidTap(draft: StoryPointDraft)
    func deleteStoryPointDidTap(draft: StoryPointDraft)
}

class StoryAddMediaTableViewCell: CSTableViewCell, UITextViewDelegate {
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
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var progressView: UIView!
    
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
        self.populateImage()
        self.manageLocation()
    }
    
    func setupViews() {
        let asset = self.draft?.asset
        self.imageViewHeightConstraint?.constant = UIScreen().screenWidth()
        let stateViewCornerRadius = CGRectGetHeight(self.orderBackView.frame) / 2
        self.orderBackView?.layer.cornerRadius = stateViewCornerRadius
        self.successView?.layer.cornerRadius = stateViewCornerRadius
        self.retryButton.layer.cornerRadius = stateViewCornerRadius
        
        self.orderBackView.hidden = (self.draft?.downloadState != .Default) && (self.draft?.downloadState != .InProgress)
        self.successView.hidden = self.draft?.downloadState != .Success
        self.retryButton.hidden = self.draft?.downloadState != .Fail
        self.retryButton.enabled = self.draft?.downloadState == .Fail
        self.retryButton.setTitle(NSLocalizedString("Button.Retry", comment: String()), forState: .Normal)
        
        self.isVideoImageView?.hidden = asset?.mediaType == .Image
        self.cropButton?.hidden = (asset?.mediaType == .Video) || (self.draft?.downloadState == .Success)
        self.deleteButton?.hidden = self.draft?.downloadState == .Success
        self.addressLabel?.text = NSLocalizedString("Label.Loading", comment: String())
        self.changeAddressButton?.setTitle(NSLocalizedString("Button.Change", comment: String()).uppercaseString, forState: .Normal)
        self.addLocationButton?.setTitle(NSLocalizedString("Button.AddLocation", comment: String()).uppercaseString, forState: .Normal)
        self.descriptionTextView?.placeholder = NSLocalizedString("Text.Placeholder.AddDescription", comment: String())
        self.descriptionTextView.delegate = self
        
        if self.draft?.downloadState == .InProgress {
            MBProgressHUD.showHUDAddedTo(self.progressView, animated: true)
        }
        self.progressView.hidden = self.draft?.downloadState != .InProgress
    }
    
    func populateOrder() {
        self.delegate?.getIndexOfObject(draft, completion: { [weak self] (index, count) in
            let order = index + 1
            let text = String(format: NSLocalizedString("Label.StoryAddInfoPostsOrder", comment: String()), order, count)
            self?.orderLabel?.text = text
            self?.successLabel?.text = text
        })
    }
    
    func populateImage() {
        AssetRetrievingManager.retrieveImage(self.draft.asset, targetSize: Sizes.assetsTargetSizeDefault, synchronous: false) { [weak self] (result, info) in
            if result != nil {
                self?.assetImageView?.image = result!
            }
        }
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
    
    @IBAction func retryTapped(sender: UIButton) {
        if self.draft != nil {
            self.retryButton.enabled = false
            self.delegate?.retryPostStoryPointDidTap(self.draft)
        }
    }
    
    @IBAction func deleteButtonTapped(sender: UIButton) {
        if self.draft != nil {
            self.delegate?.deleteStoryPointDidTap(self.draft)
        }
    }
    
    class func contentHeight() -> CGFloat {
        let imageViewHeight: CGFloat = UIScreen().screenWidth()
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        self.draft?.storyPointDescription = textView.text
    }
}
