//
//  ShareStoryPointViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import SDWebImage
import UIKit

class ShareStoryPointViewController: ViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var storyPointTitleLabel: UILabel!
    @IBOutlet weak var storyPointAddressLabel: UILabel!
    @IBOutlet weak var storyPointAddressImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shareToFacebookButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    
    var storyPointId: Int = 0
    var completion: (() -> ())! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupViews()
        self.populateViews()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.SharePost", comment: String())
    }
    
    func setupViews() {
        self.backView.layer.cornerRadius = CornerRadius.defaultRadius
        self.backView.clipsToBounds = true
        self.backView.layer.borderWidth = Border.defaultBorderWidth
        self.backView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.attachmentImageView.layer.cornerRadius = CornerRadius.defaultRadius
        self.attachmentImageView.clipsToBounds = true
        self.attachmentImageView.layer.borderWidth = Border.defaultBorderWidth
        self.attachmentImageView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.colorView.layer.cornerRadius = CornerRadius.defaultRadius
        self.colorView.clipsToBounds = true
        self.colorView.layer.borderWidth = Border.defaultBorderWidth
        self.colorView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.shareToFacebookButton.layer.cornerRadius = CornerRadius.defaultRadius
        self.shareToFacebookButton.setTitle(NSLocalizedString("Button.ShareToFacebook", comment: String()), forState: .Normal)
        
        self.copyLinkButton.layer.cornerRadius = CornerRadius.defaultRadius
        self.copyLinkButton.setTitle(NSLocalizedString("Button.CopyLink", comment: String()), forState: .Normal)
    }
    
    func populateViews() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        self.populateTitle(storyPoint)
        self.populateAddress(storyPoint)
        self.populateUserName(storyPoint)
        self.populateImageView(storyPoint)
    }
    
    func populateTitle(storyPoint: StoryPoint) {
        self.storyPointTitleLabel.text = storyPoint.caption
    }
    
    func populateAddress(storyPoint: StoryPoint) {
        self.storyPointAddressLabel.text = storyPoint.location.city
        self.storyPointAddressImageView.hidden = storyPoint.location.city == String()
    }
    
    func populateUserName(storyPoint: StoryPoint) {
        self.userNameLabel.text = storyPoint.user.profile.firstName + " " + storyPoint.user.profile.lastName
    }
    
    func populateImageView(storyPoint: StoryPoint) {
        
        let attachmentUrl = self.attachmentUrlForStoryPoint(storyPoint)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        
        self.attachmentImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if error == nil {
                self?.colorView.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
                self?.populateKindImage(storyPoint)
            }
        }
    }
    
    func populateKindImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconText)
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = UIImage()
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        }
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    @IBAction func shareToFacebookTapped(sender: UIButton) {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        let attachmentUrl = self.attachmentUrlForStoryPoint(storyPoint)
        
        let facebookShareHelper = FacebookShareHelper()
        facebookShareHelper.shareContent(self, title: storyPoint.caption, description: storyPoint.text, imageUrl: attachmentUrl, contentUrl: self.sharingParams()) { (success) in
            if success == false {
                let title = NSLocalizedString("Alert.Error", comment: String())
                let message = NSLocalizedString("Alert.SharingError", comment: String())
                let cancelButton = NSLocalizedString("Button.Ok", comment: String())
                self.showMessageAlert(title, message: message, cancel: cancelButton)
            }
        }
    }
    
    @IBAction func copyLinkTapped(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = self.sharingLink()
    }
    
    // MARK: - private
    func attachmentUrlForStoryPoint(storyPoint: StoryPoint) -> NSURL! {
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            if storyPoint.attachment != nil {
                let attachment = storyPoint.attachment as Attachment
                return NSURL(string: attachment.file_url)!
            }
        } else {
            if storyPoint.location != nil {
                return StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
            }
        }
        return nil
    }
    
    func sharingLink() -> String{
        return Network.routingPrefix + Network.sharePrefix + self.sharingParams()
    }
    
    func sharingParams() -> String {
        return SharingKeys.typeTitle + "=" + SharingKeys.typeStoryPoint + "&" + SharingKeys.typeId + "=\(self.storyPointId)"
    }
}
