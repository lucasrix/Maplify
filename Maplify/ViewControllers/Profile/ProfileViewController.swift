//
//  ProfileViewController.swift
//  Maplify
//
//  Created by Sergei on 12/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TTTAttributedLabel
import SDWebImage

let kDefaultStatsViewHeight: CGFloat = 259
let kProfileButtonBorderWidth: CGFloat = 0.5
let kAboutLabelMargin: CGFloat = 5
let kOpenProfileUrl = "openProfileUrl"

class ProfileViewController: ViewController, TTTAttributedLabelDelegate {
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
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.loadItemFromDB()
        self.setupNavigationBar()
        self.setupLabels()
        self.setupButtons()
        self.setupImage()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    func setupImage() {
        let url = NSURL(string: self.user.profile.photo)
        let placeholderImage = UIImage(named: PlaceholderImages.setPhotoPlaceholder)
        self.userImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage, completed: nil)
    }
    
    func loadItemFromDB() {
        if self.profileId == SessionManager.currentUser().id {
            self.user = SessionManager.currentUser()
        } else {
            self.user = SessionManager.findUser(self.profileId)
        }
    }
    
    // MARK: - actions
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
        self.routesOpenEditProfileController(self.profileId)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.absoluteString == kOpenProfileUrl {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}