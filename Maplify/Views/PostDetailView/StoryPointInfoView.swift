//
//  StoryPointInfoView.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointInfoView: UIView {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var storiesTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    // MARK: - setup
    func configure(storyPoint: StoryPoint) {
        self.setupLabels(storyPoint)
        self.setupStoriesTableView()
    }
    
    func setupLabels(storyPoint: StoryPoint) {
        self.addressLabel.text = storyPoint.location.address
        self.detailsTextView.text = storyPoint.text
    }
    
    func setupStoriesTableView() {
        
    }
    
    // MARK: - actions
    @IBAction func likeButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        
    }
}
