//
//  ProfileViewController.swift
//  Maplify
//
//  Created by Sergei on 12/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

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
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupLabels()
        self.setupButtons()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Profile.Title", comment: String())
    }
    
    func setupButtons() {
        if self.profileId == SessionManager.currentUser().id {
            self.editButton.hidden = false
            self.editButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.editButton.layer.borderWidth = 0.5
            self.editButton.layer.cornerRadius = CornerRadius.defaultRadius

        } else {
            self.followButton.hidden = false
            self.followButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.followButton.layer.borderWidth = 0.5
            self.followButton.layer.cornerRadius = CornerRadius.defaultRadius
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