//
//  EditStoryTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import KMPlaceholderTextView
import CoreLocation
import UIKit

let kTextStoryPointImageViewHeight: CGFloat = 56
let kDescriptionMaxCharactersCount: Int = 1500

protocol EditStoryTableViewCellDelegate {
    func getIndexOfObject(draft: StoryPointDraft, completion: ((index: Int, count: Int) -> ())!)
    func changeLocationDidTap(completion: ((location: CLLocationCoordinate2D, address: String) -> ())!)
}

class EditStoryTableViewCell: CSTableViewCell, UITextViewDelegate {
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var kindImageView: UIImageView!
    @IBOutlet weak var kindImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeAddressButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!

    var draft: StoryPointDraft! = nil
    var delegate: EditStoryTableViewCellDelegate! = nil
    
    override func configure(cellData: CSCellData) {
        self.draft = cellData.model as! StoryPointDraft
        self.delegate = cellData.delegate as! EditStoryTableViewCellDelegate
        
        self.setupViews()
        self.populateOrder()
        self.populateImage()
        self.populateLocation()
        self.populateDescription()
    }
    
    func setupViews() {
        let stateViewCornerRadius = CGRectGetHeight(self.orderView.frame) / 2
        self.orderView?.layer.cornerRadius = stateViewCornerRadius
        self.changeAddressButton?.setTitle(NSLocalizedString("Button.Change", comment: String()).uppercaseString, forState: .Normal)
        self.descriptionTextView.delegate = self
    }
    
    func populateOrder() {
        self.delegate?.getIndexOfObject(self.draft, completion: { [weak self] (index, count) in
            let order = index + 1
            let text = String(format: NSLocalizedString("Label.StoryAddInfoPostsOrder", comment: String()), order, count)
            self?.orderLabel?.text = text
        })
    }
    
    func populateImage() {
        var attachmentUrl: NSURL! = nil
        var placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        if self.draft.storyPointKind == StoryPointKind.Photo.rawValue {
            attachmentUrl = self.draft.attachmentUrl.url
        } else if (self.draft.storyPointKind == StoryPointKind.Video.rawValue) || (self.draft.storyPointKind == StoryPointKind.Audio.rawValue) {
            attachmentUrl = StaticMap.staticMapUrl(self.draft.coordinate.latitude, longitude: self.draft.coordinate.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        } else {
            placeholderImage = nil
        }
        self.colorView?.hidden = self.draft.storyPointKind != StoryPointKind.Audio.rawValue
        self.attachmentImageView.pin_setImageFromURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (result) in
            self?.kindImageView?.image = self?.kindImageForStoryPoint()
        }
    }
    
    func populateLocation() {
        self.locationLabel?.text = self.draft?.address
    }
    
    func populateDescription() {
        self.descriptionTextView?.text = self.draft?.storyPointDescription
    }
    
    func kindImageForStoryPoint() -> UIImage! {
        switch self.draft.storyPointKind {
        case StoryPointKind.Audio.rawValue:
            return UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
            
        case StoryPointKind.Video.rawValue:
            return UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
            
        default:
            return nil
        }
    }
    
    // MARK: - actions
    @IBAction func changeLocationTapped(sender: UIButton) {
        self.delegate?.changeLocationDidTap({ [weak self] (location, address) in
            self?.draft?.address = address
            self?.draft?.coordinate = location
            self?.populateLocation()
        })
    }
    
    class func imageViewHeight(draft: StoryPointDraft) -> CGFloat {
        return draft.storyPointKind == StoryPointKind.Text.rawValue ? kTextStoryPointImageViewHeight : UIScreen().screenWidth()
    }
    
    class func contentHeight(cellData: CSCellData) -> CGFloat {
        let draft = cellData.model as! StoryPointDraft
        let imageViewHeight = EditStoryTableViewCell.imageViewHeight(draft)
        return kCellTopMargin + imageViewHeight + kCellLocationViewHeight + kCellDescriptionViewHeight
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let resultText = (self.descriptionTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if resultText.characters.count <= kDescriptionMaxCharactersCount {
            self.draft?.storyPointDescription = resultText
            return true
        }
        return false
    }
}
