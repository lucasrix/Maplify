//
//  StoryDetailItemViewController.swift
//  Maplify
//
//  Created by - Jony - on 4/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kStoryDetailScrollViewExpandHeight: CGFloat = 44

let kStoryPointDescriptionOpened: Int = 0
let kStoryPointDescriptionClosed: Int = 1

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
    @IBOutlet weak var attachmentContentView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    
    var itemIndex: Int = 0
    var storyPointId: Int = 0
    var storyPoint: StoryPoint! = nil
    var descriptionOpened: Bool = false
    var stackSupport: Bool = false

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
        let storyPoint = StoryPointManager.find(self.storyPointId)
        self.storyPoint = storyPoint
        self.populateUserViews()
        self.populateStoryPointInfoViews()
        self.populateAttachment()
        self.populateDescriptionLabel()
        self.populateLikeButton()
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
        self.captionLabel.text = self.storyPoint.caption
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
        self.descriptionLabel.numberOfLines = self.descriptionOpened || self.storyPoint.kind == StoryPointKind.Text.rawValue ? kStoryPointDescriptionOpened : kStoryPointDescriptionClosed
        
        if self.descriptionOpened {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(self.storyPoint.text) || self.storyPoint.kind == StoryPointKind.Text.rawValue
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(self.storyPoint.text) || self.storyPoint.kind == StoryPointKind.Text.rawValue
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.descriptionOpened = !self.descriptionOpened
        self.populateDescriptionLabel()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func jumpToDiscoverFeedTapped(sender: UIButton) {
        if self.stackSupport == false {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        super.backTapped()
    }
    
    @IBAction func editContentTapped(sender: UIButton) {
        if storyPoint.user.profile.id == SessionManager.currentUser().profile.id {
            
            self.showStoryPointEditContentActionSheet( { [weak self] (selectedIndex) -> () in
                
                if selectedIndex == StoryPointEditContentOption.EditPost.rawValue {
                    self?.routesOpenStoryPointEditController((self?.storyPointId)!, storyPointUpdateHandler: { [weak self] in
                        self?.setupData()
                        })
                } else if selectedIndex == StoryPointEditContentOption.DeletePost.rawValue {
                    self?.deleteStoryPoint()
                } else if selectedIndex == StoryPointEditContentOption.SharePost.rawValue {
                    self?.shareStoryPoint()
                }
                })
        } else {
            self.showStoryPointDefaultContentActionSheet( { [weak self] (selectedIndex) in
                
                if selectedIndex == StoryPointDefaultContentOption.SharePost.rawValue {
                    self?.shareStoryPoint()
                }
            })
        }
    }
    
    @IBAction func likeTapped(sender: UIButton) {
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint.liked {
            self.unlikeStoryPoint()
        } else {
            self.likeStoryPoint()
        }
    }
    
    // MARK: - private
    func deleteStoryPoint() {
        // TODO:
    }
    
    func shareStoryPoint() {
        self.routesOpenShareStoryPointViewController(self.storyPointId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    @IBAction func openContentTapped(sender: UITapGestureRecognizer) {
        if self.storyPoint.kind == StoryPointKind.Video.rawValue {
            PlayerHelper.sharedPlayer.playVideo((storyPoint?.attachment.file_url)!, onView: self.attachmentContentView)
        } else if self.storyPoint.kind == StoryPointKind.Audio.rawValue {
            PlayerHelper.sharedPlayer.playAudio((storyPoint?.attachment?.file_url)!, onView: self.attachmentContentView)
        }
        self.attachmentContentView.hidden = self.storyPoint.kind == StoryPointKind.Text.rawValue || self.storyPoint.kind == StoryPointKind.Photo.rawValue
    }
    
    private func likeStoryPoint() {
        ApiClient.sharedClient.likeStoryPoint(self.storyPointId, success: { [weak self] (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            self?.populateLikeButton()
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    private func unlikeStoryPoint() {
        ApiClient.sharedClient.unlikeStoryPoint(self.storyPointId, success: { [weak self] (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            self?.populateLikeButton()
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func populateLikeButton() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint.liked {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLikeHighlited), forState: .Normal)
        } else {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLike), forState: .Normal)
        }
    }
    
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
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
