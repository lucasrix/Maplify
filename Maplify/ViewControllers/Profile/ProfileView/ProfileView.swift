//
//  ProfileView.swift
//  Maplify
//
//  Created by Sergei on 25/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SDWebImage
import CoreLocation

let kDefaultContentHeight: CGFloat = 360
let kDefaultContentWithButtonHeight: CGFloat = 420
let kMapGradientOpacity: CGFloat = 0.85
let kProfileButtonBorderWidth: CGFloat = 0.5
let kAboutLabelMargin: CGFloat = 5
let kShadowYOffset: CGFloat = -3
let kDefaultLabelHeight: CGFloat = 36

protocol ProfileViewDelegate {
    func followButtonDidTap(userId: Int, completion: ((success: Bool) -> ()))
    func editButtonDidTap()
    func createStoryButtonDidTap()
    func followingUsersTapped()
    func followersUsersTapped()
}

class ProfileView: UIView, TTTAttributedLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FollowingListDelegate {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLogo: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var profileUrlLabel: TTTAttributedLabel!
    @IBOutlet weak var statsParentView: UIView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var locationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var locationLogoHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var urlLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var createStoryButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var createStoryButtonTop: NSLayoutConstraint!
    @IBOutlet weak var statsParentViewBottomConstraint: NSLayoutConstraint!
    
    var profileId: Int = 0
    var user: User! = nil
    var imagePicker: UIImagePickerController! = nil
    var placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
    var publicStatsView: PublicStatsView! = nil
    var privateStatsView: PrivateStatsView! = nil
    var updateContentClosure: (() -> ())! = nil
    var didChangeImageClosure: (() -> ())! = nil
    var parentViewController: UIViewController! = nil
    var delegate: ProfileViewDelegate! = nil
    var contentHeightValue: CGFloat = 0
    
    func setupWithUser(profileId: Int, parentViewController: UIViewController) {
        self.profileId = profileId
        self.parentViewController = parentViewController
        self.setup()
    }
    
    func setup() {
        self.loadItemFromDB()
        self.setupImageView()
        self.setupLabels()
        self.setupButtons()
        self.populateFollowButton()
        self.setupCreateButton()
        self.loadRemoteData()
        self.setupDetailStatsView()
        self.setupDetailedLabels()
        self.setupBackgroundMap()
        self.setupInitialContentHeight()
    }
    
    func setupDetailStatsView() {
        if self.profileId != SessionManager.currentUser().id {
            self.statsParentViewBottomConstraint.constant = 0
        }
        self.statsParentView.subviews.forEach({ $0.removeFromSuperview() })
        if self.profileId == SessionManager.currentUser().id {
            self.setupPrivateStatsView()
        } else {
            self.setupPublicStatsView()
        }
    }
    
    func setupPublicStatsView() {
        self.publicStatsView = NSBundle.mainBundle().loadNibNamed(String(PublicStatsView), owner: self, options: nil).first as? PublicStatsView
        self.publicStatsView.frame = self.statsParentView.bounds
        self.publicStatsView.storiesLabel.text = NSLocalizedString("Label.Stories", comment: String())
        self.publicStatsView.postsLabel.text = NSLocalizedString("Label.Posts", comment: String())
        self.statsParentView.addSubview(self.publicStatsView)
    }
    
    func setupPrivateStatsView() {
        self.privateStatsView = NSBundle.mainBundle().loadNibNamed(String(PrivateStatsView), owner: self, options: nil).first as? PrivateStatsView
        self.privateStatsView.frame = self.statsParentView.bounds
        self.privateStatsView.storiesLabel.text = NSLocalizedString("Label.Stories", comment: String())
        self.privateStatsView.postsLabel.text = NSLocalizedString("Label.Posts", comment: String())
        self.privateStatsView.followersLabel.text = NSLocalizedString("Label.Followers", comment: String())
        self.privateStatsView.followinfLabel.text = NSLocalizedString("Label.Following", comment: String())
        self.privateStatsView.delegate = self
        self.statsParentView.addSubview(self.privateStatsView)
    }
    
    func setupLabels() {
        self.usernameLabel.text = self.user.profile.firstName + " " + self.user.profile.lastName
        self.aboutLabel.text = self.user.profile.about
        
        if self.user.profile.city.length > 0 {
            self.locationLabel.text = self.user.profile.city
            self.locationLabelHeight.constant = kDefaultLabelHeight
        } else {
            self.locationLabelHeight.constant = 0
            self.locationLogo.hidden = true
        }
        
        if self.user.profile.url.length > 0 {
            self.urlLabelHeightConstraint.constant = kDefaultLabelHeight
            self.profileUrlLabel.text = self.user.profile.url
            self.profileUrlLabel.setupDefaultAttributes(self.user.profile.url, textColor: UIColor.dodgerBlue(), font: self.profileUrlLabel.font, delegate: self)
            self.profileUrlLabel.setupLinkAttributes(UIColor.dodgerBlue(), underlined: true)
            self.profileUrlLabel.addURLLink(self.user.profile.url, str: self.user.profile.url, rangeStr: self.user.profile.url)
        } else {
            self.urlLabelHeightConstraint.constant = 0
            self.profileUrlLabel.text = String()
        }
    }
    
    func setupBackgroundMap() {
        let location = self.user.profile.location
        
        var attachmentUrl: NSURL! = nil
        
        if location != nil {
            attachmentUrl = StaticMap.staticMapUrl(location.latitude, longitude: location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        } else {
            let defaultLocation = CLLocation(latitude: DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
            attachmentUrl = StaticMap.staticMapUrl(defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: true)
        }
        
        self.mapImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: nil) { [weak self] (image, error, cacheType, url) in
            if error == nil {
                self?.mapImageView.image = image
                self?.addMapGradient()
            }
        }
    }
    
    func addMapGradient() {
        self.mapImageView.layer.sublayers = nil
        let gradient = CAGradientLayer()
        gradient.frame = self.mapImageView.bounds
        gradient.colors = [UIColor.darkGreyBlue().colorWithAlphaComponent(kMapGradientOpacity).CGColor, UIColor.darkerGreyBlue().CGColor]
        self.mapImageView.layer.addSublayer(gradient)
    }
    
    func setupDetailedLabels() {
        self.likesLabel.text = String(self.user.profile.likes_count)
        self.plusLabel.text = String(self.user.profile.saves_count)
        
        if self.profileId == SessionManager.currentUser().id {
            self.privateStatsView.followersNumberLabel.text = String(self.user.profile.followers_count)
            self.privateStatsView.followingNumberLabel.text = String(self.user.profile.followings_count)
            self.privateStatsView.storiesNumberLabel.text = String(self.user.profile.stories_count)
            self.privateStatsView.postsNumberLabel.text = String(self.user.profile.story_points_count)
        } else {
            self.publicStatsView.postsNumberLabel.text = String(self.user.profile.story_points_count)
            self.publicStatsView.stortiesNumberLabel.text = String(self.user.profile.stories_count)
        }
    }
    
    func setupButtons() {
        if self.profileId == SessionManager.currentUser().id {
            self.editButton.hidden = false
            self.editButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.editButton.layer.borderWidth = kProfileButtonBorderWidth
            self.editButton.layer.cornerRadius = CornerRadius.defaultRadius
        } else {
            self.followButton.hidden = false
            self.followButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.followButton.layer.borderWidth = kProfileButtonBorderWidth
            self.followButton.layer.cornerRadius = CornerRadius.defaultRadius
        }
        self.expandButton.hidden = !(self.user.profile.about.length > 0)
    }
    
    func populateFollowButton() {
        let user = SessionManager.findUser(self.profileId)
        if user != nil && user.followed {
            self.followButton.setTitle(NSLocalizedString("Button.Following", comment: String()), forState: .Normal)
        } else {
            self.followButton.setTitle(NSLocalizedString("Button.PlusFollow", comment: String()), forState: .Normal)
        }
    }
    
    func setupCreateButton() {
        if self.profileId == SessionManager.currentUser().id {
            self.createStoryButton.layer.cornerRadius = CornerRadius.defaultRadius
        } else {
            self.createStoryButtonHeight.constant = 0
            self.createStoryButtonTop.constant = 0
            self.createStoryButton.hidden = true
        }
    }
    
    func setupImageView() {
        let url = NSURL(string: self.user.profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
        
        
        self.userImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [.RefreshCached], completed: nil)
        
        if self.profileId == SessionManager.currentUser().id {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileView.imageViewDidTap))
            self.userImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    func setupInitialContentHeight() {
        self.contentHeightValue = (self.profileId == SessionManager.currentUser().id) ? kDefaultContentWithButtonHeight : kDefaultContentHeight
    }
    
    func loadItemFromDB() {
        if self.profileId == SessionManager.currentUser().id {
            self.user = SessionManager.currentUser()
        } else {
            self.user = SessionManager.findUser(self.profileId)
        }
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.getProfileInfo(self.user.profile.id, success: { [weak self] (response) in
            let profile = response as! Profile
            ProfileManager.saveProfile(profile)
            self?.loadItemFromDB()
            self?.setupLabels()
            }, failure: nil)
    }
    
    func contentHeight() -> CGFloat {
        return self.contentHeightValue
    }
    
    // MARK: - actions
    func imageViewDidTap() {
        self.showPhotoActionSheet()
    }
    
    func showPhotoActionSheet() {
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let message = NSLocalizedString("Alert.SetPhoto", comment: String())
        let existingPhoto = NSLocalizedString("Button.ExistingPhoto", comment: String())
        let takePhoto = NSLocalizedString("Button.TakePhoto", comment: String())
        
        self.parentViewController.showActionSheet(nil, message: message, cancel: cancel, destructive: nil, buttons: [existingPhoto, takePhoto],
                             handle: { [weak self] (buttonIndex) -> () in
                                if ActionSheetButtonType(rawValue: buttonIndex) == .ExistingPhotoType {
                                    self?.showImagePicker(.PhotoLibrary)
                                } else if ActionSheetButtonType(rawValue: buttonIndex) == .TakeNewPhotoType {
                                    self?.showImagePicker(.Camera)
                                }
            })
    }
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        if (self.imagePicker == nil) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
        }
        self.imagePicker.sourceType = sourceType
        self.parentViewController.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func createStoryButtonTapped(sender: AnyObject) {
        self.delegate?.createStoryButtonDidTap()
    }
    
    @IBAction func expandButtonTapped(sender: AnyObject) {
        self.expandButton.selected = !self.expandButton.selected
        
        let baseContentHeight = (self.profileId == SessionManager.currentUser().id) ? kDefaultContentWithButtonHeight : kDefaultContentHeight
        
        if self.expandButton.selected {
            let font = self.aboutLabel.font
            let boundingRect = CGRectMake(0, 0, self.aboutLabel.frame.size.width, CGFloat.max)
            let textHeight = self.user.profile.about.size(font, boundingRect: boundingRect).height
            self.aboutLabel.text = self.user.profile.about
            self.contentHeightValue = baseContentHeight + CGFloat(ceilf(Float(textHeight))) + 2 * kAboutLabelMargin
            self.aboutLabelHeight.constant = CGFloat(ceilf(Float(textHeight))) + 2 * kAboutLabelMargin
        } else {
            self.contentHeightValue = baseContentHeight
            self.aboutLabelHeight.constant = 0
        }
        
        self.updateContentClosure()
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        self.delegate?.followButtonDidTap(self.profileId, completion: { [weak self] (success) in
            if success {
                self?.populateFollowButton()
            }
        })
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        self.delegate?.editButtonDidTap()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImageView.image = pickedImage.correctlyOrientedImage().roundCornersToCircle()
            self.didChangeImageClosure()
        }
        self.parentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if UIApplication.sharedApplication().canOpenURL(url.byAddingPrefixIfNeeded()) {
            UIApplication.sharedApplication().openURL(url.byAddingPrefixIfNeeded())
        }
    }
    
    // MARK: - FollowingListDelegate
    func followingTapped() {
        self.delegate?.followingUsersTapped()
    }
    
    func followersTapped() {
        self.delegate?.followersUsersTapped()
    }
}