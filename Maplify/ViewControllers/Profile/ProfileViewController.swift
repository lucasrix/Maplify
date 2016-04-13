//
//  ProfileViewController.swift
//  Maplify
//
//  Created by Sergei on 12/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kProfileButtonBorderWidth: CGFloat = 0.5

class ProfileViewController: ViewController {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLogo: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var statsParentView: UIView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var aboutLabelHeightConstraint: NSLayoutConstraint!
    
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
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Profile.Title", comment: String())
        self.usernameLabel.text = self.user.profile.firstName + " " + self.user.profile.lastName
        
        if self.user.profile.city.length > 0 {
            self.locationLabel.text = self.user.profile.city
        }
        
        if self.user.profile.url.length > 0 {
            self.urlLabel.text = self.user.profile.url
        }
        
        if self.user.profile.about.length > 0 {
            self.aboutLabel.text = self.user.profile.about
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
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        //TODO: -
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        //TODO: -
    }
}