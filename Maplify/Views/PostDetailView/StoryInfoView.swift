//
//  StoryInfoView.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

protocol StoryInfoViewDelegate {
    func profileImageTapped(userId: Int)
    func didSelectStory(storyId: Int)
    func likeStoryDidTap(storyPointId: Int, completion: ((success: Bool) -> ()))
    func shareStoryDidTap(storyPointId: Int)
}

class StoryInfoView: UIView, UIScrollViewDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var backUserImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userId: Int = 0
    var storyId: Int = 0
    var delegate: StoryInfoViewDelegate! = nil
    
    // MARK: - setup
    func configure(story: Story) {
        self.setupUserViews(story)
        self.setupContentSize()
    }
    
    func setupUserViews(story: Story) {
        let user = story.user as User
        let profile = user.profile as Profile
        self.userId = user.id
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.userImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryPointInfoView.profileImageTapped))
        self.userImageView.addGestureRecognizer(tapGesture)
        
        self.backUserImageView.image = UIImage(color: UIColor.whiteColor())?.roundCornersToCircle()
        self.backUserImageView.layer.cornerRadius = CGRectGetHeight(self.backUserImageView.frame) / 2
        self.backUserImageView.layer.masksToBounds = true
        
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
    }
    
    // MARK: - actions
    func profileImageTapped() {
        self.delegate?.profileImageTapped(self.userId)
    }
    
    func setupContentSize() {
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSizeMake(0, 1000)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y)
    }
    
}