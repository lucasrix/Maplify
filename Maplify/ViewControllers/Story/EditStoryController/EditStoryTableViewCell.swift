//
//  EditStoryTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import KMPlaceholderTextView
import UIKit

let kTextStoryPointImageViewHeight: CGFloat = 56

protocol EditStoryTableViewCellDelegate {
    func getIndexOfObject(storyPoint: StoryPoint, completion: ((index: Int, count: Int) -> ())!)
}

class EditStoryTableViewCell: CSTableViewCell {
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var kindImageView: UIImageView!
    @IBOutlet weak var changeAddressButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!

    var storyPoint: StoryPoint! = nil
    var delegate: EditStoryTableViewCellDelegate! = nil
    
    override func configure(cellData: CSCellData) {
        self.storyPoint = cellData.model as! StoryPoint
        self.delegate = cellData.delegate as! EditStoryTableViewCellDelegate
        
        self.setupViews()
        self.populateOrder()
        self.populateImage()
        self.populateLocation()
        self.populateDescription()
    }
    
    func setupViews() {
        self.attachmentImageViewHeightConstraint.constant = EditStoryTableViewCell.imageViewHeight(self.storyPoint)
        let stateViewCornerRadius = CGRectGetHeight(self.orderView.frame) / 2
        self.orderView?.layer.cornerRadius = stateViewCornerRadius
        self.changeAddressButton?.setTitle(NSLocalizedString("Button.Change", comment: String()).uppercaseString, forState: .Normal)
    }
    
    func populateOrder() {
        self.delegate?.getIndexOfObject(self.storyPoint, completion: { [weak self] (index, count) in
            let order = index + 1
            let text = String(format: NSLocalizedString("Label.StoryAddInfoPostsOrder", comment: String()), order, count)
            self?.orderLabel?.text = text
        })
    }
    
    func populateImage() {
        var attachmentUrl: NSURL! = nil
        var placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            attachmentUrl = storyPoint.attachment.file_url.url
        } else if (storyPoint.kind == StoryPointKind.Video.rawValue) || (storyPoint.kind == StoryPointKind.Audio.rawValue) {
            attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        } else {
            placeholderImage = nil
        }
        self.colorView?.hidden = self.storyPoint.kind != StoryPointKind.Audio.rawValue
        self.attachmentImageView.pin_setImageFromURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (result) in
            self?.kindImageView?.image = self?.kindImageForStoryPoint()
        }
    }
    
    func populateLocation() {
        self.locationLabel?.text = self.storyPoint?.location.address
    }
    
    func populateDescription() {
        self.descriptionTextView?.text = self.storyPoint?.text
    }
    
    func kindImageForStoryPoint() -> UIImage! {
        switch self.storyPoint.kind {
        case StoryPointKind.Audio.rawValue:
            return UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
            
        case StoryPointKind.Video.rawValue:
            return UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
            
        default:
            return nil
        }
    }
    
    class func imageViewHeight(storyPoint: StoryPoint) -> CGFloat {
        return storyPoint.kind == StoryPointKind.Text.rawValue ? kTextStoryPointImageViewHeight : UIScreen().screenWidth()
    }
    
    class func contentHeight(cellData: CSCellData) -> CGFloat {
        let storyPoint = cellData.model as! StoryPoint
        let imageViewHeight = EditStoryTableViewCell.imageViewHeight(storyPoint)
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
}
