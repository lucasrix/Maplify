//
//  FollowingTableViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class FollowingTableViewCell: CSTableViewCell {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var userId: Int = 0
    var delegate: FollowingCellDelegate! = nil
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        let user = cellData.model as! User
        self.userId = user.id
        self.delegate = cellData.delegate as! FollowingCellDelegate
        self.setupViews()
        self.populateLabels(user)
        self.populateFollowButton()
    }
    
    func setupViews() {
        self.followButton.layer.cornerRadius = CornerRadius.defaultRadius
        self.followButton.layer.borderWidth = Border.defaultBorderWidth
        self.followButton.layer.borderColor = UIColor.darkGreyBlue().CGColor
    }
    
    func populateLabels(user: User) {
        let profile = user.profile as Profile
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.thumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FollowingTableViewCell.profileImageTapped))
        self.thumbImageView.addGestureRecognizer(tapGesture)
        
        self.usernameLabel.text = profile.firstName + " " + profile.lastName
        self.addressLabel.text = profile.city
    }
    
    func populateFollowButton() {
        let user = SessionManager.findUser(self.userId)
        if user.followed {
            self.followButton.setTitle(NSLocalizedString("Button.Following", comment: String()), forState: .Normal)
            self.followButton.backgroundColor = UIColor.darkGreyBlue()
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        } else {
            self.followButton.setTitle(NSLocalizedString("Button.PlusFollow", comment: String()), forState: .Normal)
            self.followButton.backgroundColor = UIColor.clearColor()
            self.followButton.setTitleColor(UIColor.darkGreyBlue(), forState: .Normal)
        }
    }
    
    // MARK: - actions
    @IBAction func followTapped(sender: UIButton) {
        self.delegate?.followUser(self.userId, completion: { [weak self] (success) in
            if success {
                self?.populateFollowButton()
            }
        })
    }
    
    // MARK: - private
    func profileImageTapped() {
        self.delegate?.openProfile(self.userId)
    }
}

protocol FollowingCellDelegate {
    func followUser(userId: Int, completion: ((success: Bool) -> ())!)
    func openProfile(userId: Int)
}
