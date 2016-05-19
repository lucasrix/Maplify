//
//  ShareStoryViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/28/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class ShareStoryViewController: ViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyAddressLabel: UILabel!
    @IBOutlet weak var storyAddressImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shareToFacebookButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    @IBOutlet weak var storyPointsCountLabel: UILabel!
    
    var storyId: Int = 0
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
        self.title = NSLocalizedString("Controller.ShareStory", comment: String())
    }
    
    func setupViews() {
        self.backView.layer.cornerRadius = CornerRadius.defaultRadius
        self.backView.clipsToBounds = true
        self.backView.layer.borderWidth = Border.defaultBorderWidth
        self.backView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
        self.backgroundImageView.layer.cornerRadius = CornerRadius.defaultRadius
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.layer.borderWidth = Border.defaultBorderWidth
        self.backgroundImageView.layer.borderColor = UIColor.inactiveGrey().CGColor
        
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
        let story = StoryManager.find(self.storyId)
        self.populateStoryPointsCount(story)
        self.populateBackgroundImage(story)
        self.populateTitle(story)
        self.populateAddress(story)
        self.populateUserName(story)
    }
    
    func populateStoryPointsCount(story: Story) {
        let substringPoints = story.storyPoints.count % 10 == 1 ? NSLocalizedString("Substring.Point", comment: String()) : NSLocalizedString("Substring.Points", comment: String())
        self.storyPointsCountLabel.text = "\(story.storyPoints.count) " + substringPoints
    }
    
    func populateBackgroundImage(story: Story) {
        let storyPoint: StoryPoint = story.storyPoints.first!
        if storyPoint.location != nil {
            let imageUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthSmall, showWholeWorld: false)
            self.backgroundImageView.sd_setImageWithURL(imageUrl)
        }
    }
    
    func populateTitle(story: Story) {
        self.storyTitleLabel.text = story.title
    }
    
    func populateAddress(story: Story) {
        // TODO:
        let substringPoints = story.storyPoints.count % 10 == 1 ? NSLocalizedString("Substring.Point", comment: String()) : NSLocalizedString("Substring.Points", comment: String())
        self.storyAddressLabel.text = "\(story.storyPoints.count) " + substringPoints
    }
    
    func populateUserName(story: Story) {
        self.userNameLabel.text = story.user.profile.firstName + " " + story.user.profile.lastName
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
        let story = StoryManager.find(self.storyId)
        let firstStoryPoint = story.storyPoints.first
        let attachmentUrl = StaticMap.staticMapUrl(firstStoryPoint!.location.latitude, longitude: firstStoryPoint!.location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        
        let facebookShareHelper = FacebookShareHelper()
        facebookShareHelper.shareContent(self, title: story.title, description: story.storyDescription, imageUrl: attachmentUrl, contentUrl: self.sharingParams()) { (success) in
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
    
    func sharingLink() -> String{
        return Network.routingPrefix + Network.sharePrefix + self.sharingParams()
    }
    
    func sharingParams() -> String {
        return SharingKeys.typeTitle + "=" + SharingKeys.typeStory + "&" + SharingKeys.typeId + "=\(self.storyId)"
    }
}
