//
//  ProfileViewController.swift
//  Maplify
//
//  Created by Sergei on 12/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TTTAttributedLabel
import SDWebImage
import AFImageHelper

let kDefaultStatsViewHeight: CGFloat = 259
let kProfileButtonBorderWidth: CGFloat = 0.5
let kAboutLabelMargin: CGFloat = 5
let kOpenProfileUrl = "openProfileUrl"
let kShadowYOffset: CGFloat = -3

class ProfileViewController: ViewController, TTTAttributedLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    @IBOutlet weak var urlLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var profileId: Int = 0
    var user: User! = nil
    var imagePicker: UIImagePickerController! = nil
    var placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
    var publicStatsView: PublicStatsView! = nil
    var privateStatsView: PrivateStatsView! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.setupImageView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadItemFromDB()
        self.setupLabels()
        self.setupButtons()
        self.loadRemoteData()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupDetailStatsView()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, kShadowYOffset)
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
    }
    
    func setupDetailStatsView() {
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
        self.statsParentView.addSubview(self.privateStatsView)
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Profile.Title", comment: String())
        self.usernameLabel.text = self.user.profile.firstName + " " + self.user.profile.lastName
        
        if self.user.profile.city.length > 0 {
            self.locationLabel.text = self.user.profile.city
        } else {
            self.locationLabelHeight.constant = 0
            self.locationLogo.hidden = true
        }
        
        if self.user.profile.url.length > 0 {
            self.profileUrlLabel.text = self.user.profile.url
            
            self.profileUrlLabel.setupDefaultAttributes(self.user.profile.url, textColor: UIColor.dodgerBlue(), font: self.profileUrlLabel.font, delegate: self)
            self.profileUrlLabel.setupLinkAttributes(UIColor.dodgerBlue(), underlined: true)
            self.profileUrlLabel.addURLLink(kOpenProfileUrl, str: self.user.profile.url, rangeStr: self.user.profile.url)
        } else {
            self.urlLabelHeight.constant = 0
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
    
    func setupImageView() {
        let url = NSURL(string: SessionManager.currentUser().profile.photo)
        let placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
        self.userImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [.RefreshCached], completed: nil)
        
        if self.profileId == SessionManager.currentUser().id {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.imageViewDidTap))
            self.userImageView.addGestureRecognizer(tapGesture)
        }
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
    
    // MARK: - actions
    func imageViewDidTap() {
        self.showPhotoActionSheet()
    }
    
    func showPhotoActionSheet() {
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let message = NSLocalizedString("Alert.SetPhoto", comment: String())
        let existingPhoto = NSLocalizedString("Button.ExistingPhoto", comment: String())
        let takePhoto = NSLocalizedString("Button.TakePhoto", comment: String())
        
        self.showActionSheet(nil, message: message, cancel: cancel, destructive: nil, buttons: [existingPhoto, takePhoto],
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
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }

    
    @IBAction func expandButtonTapped(sender: AnyObject) {
        self.expandButton.selected = !self.expandButton.selected
        if self.expandButton.selected {
            let font = self.aboutLabel.font
            let boundingRect = CGRectMake(0, 0, self.aboutLabel.frame.size.width, CGFloat.max)
            let textHeight = self.user.profile.about.size(font, boundingRect: boundingRect).height
            self.aboutLabel.text = self.user.profile.about
            self.contentViewHeight.constant = kDefaultStatsViewHeight + textHeight + 2 * kAboutLabelMargin
            self.profileUrlLabel.hidden = false
        } else {
            self.contentViewHeight.constant = kDefaultStatsViewHeight
            self.profileUrlLabel.hidden = true
        }
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        //TODO: -
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        self.routesOpenEditProfileController(self.profileId, photo: self.userImageView.image)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImageView.image = pickedImage.correctlyOrientedImage().roundCornersToCircle()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.absoluteString == kOpenProfileUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}