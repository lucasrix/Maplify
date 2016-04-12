//
//  StoryDetailItemViewController.swift
//  Maplify
//
//  Created by - Jony - on 4/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kStoryDetailScrollViewExpandHeight: CGFloat = 44

class StoryDetailItemViewController: ViewController, UIScrollViewDelegate {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var storyPointAddressLabel: UILabel!
    @IBOutlet weak var storyPointAddressImageView: UIImageView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionButton: UIButton!
    @IBOutlet weak var firstBackShadowView: UIView!
    @IBOutlet weak var backShadowView: UIView!
    @IBOutlet weak var attachmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jumpToFeedButton: UIButton!
    
    var itemIndex: Int = 0
    var storyPoint: StoryPoint! = nil
    var descriptionOpened: Bool = false

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.addShadow()
        self.setupData()
        self.setupScrollView()
    }
    
    func addShadow() {
        self.backShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.backShadowView.layer.shadowOpacity = kShadowOpacity
        self.backShadowView.layer.shadowOffset = CGSizeZero
        self.backShadowView.layer.shadowRadius = kShadowRadius
        
        self.firstBackShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.firstBackShadowView.layer.shadowOpacity = kShadowOpacity
        self.firstBackShadowView.layer.shadowOffset = CGSizeZero
        self.firstBackShadowView.layer.shadowRadius = kShadowRadius
    }
    
    func setupData() {
        self.populateUserViews()
        self.populateStoryPointInfoViews()
        self.populateAttachment()
        self.populateDescriptionLabel()
    }
    
    func setupScrollView() {
        self.scrollView.delegate = self
        self.jumpToFeedButton.setTitle(NSLocalizedString("Button.JumpToDiscoverFeed", comment: String()), forState: .Normal)
    }
    
    func populateUserViews() {
        let user = self.storyPoint.user as User
        let profile = user.profile as Profile
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.photo)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.thumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        self.usernameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city
    }
    
    func populateStoryPointInfoViews() {
        self.captionLabel.text = storyPoint.text
    }
    
    func populateAttachment() {
        var attachmentUrl: NSURL! = nil
        let placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        if self.storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.attachmentHeightConstraint.constant = UIScreen().screenWidth()
            attachmentUrl = self.storyPoint.attachment.file_url.url
        } else if self.storyPoint.kind == StoryPointKind.Text.rawValue {
            self.attachmentHeightConstraint.constant = 0.0
            attachmentUrl = nil
        } else {
            self.attachmentHeightConstraint.constant = UIScreen().screenWidth()
            attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge)
        }
        self.attachmentImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if error == nil {
                self?.colorView.alpha = self?.storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
                self?.populateKindImage()
            }
        }
    }
    
    func populateKindImage() {
        if self.storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconText)
        } else if self.storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = UIImage()
        } else if self.storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if self.storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        }
    }
    
    func populateDescriptionLabel() {
        self.descriptionLabel.text = self.storyPoint.text
        self.descriptionLabel.numberOfLines = self.descriptionOpened ? kStoryPointDescriptionOpened : kStoryPointDescriptionClosed
        
        if self.descriptionOpened {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(self.storyPoint.text)
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(self.storyPoint.text)
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.descriptionOpened = !self.descriptionOpened
        self.populateDescriptionLabel()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func jumpToDiscoverFeedTapped(sender: UIButton) {
        self.parentViewController?.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - private
    func showHideButtonHidden(text: String) -> Bool {
        let font = self.descriptionLabel.font
        let textWidth: CGFloat = CGRectGetWidth(self.descriptionLabel.frame)
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        return textSize.height <= kStoryPointCellDescriptionDefaultHeight
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.grapePurple()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 && scrollView.contentOffset.y > -kStoryDetailScrollViewExpandHeight {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: -scrollView.contentOffset.y, right: 0)
        }
    }
}
