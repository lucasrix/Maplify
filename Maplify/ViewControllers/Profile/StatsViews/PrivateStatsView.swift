//
//  PrivateStatsView.swift
//  Maplify
//
//  Created by Sergei on 13/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class PrivateStatsView: UIView {
    @IBOutlet weak var postsNumberLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var storiesNumberLabel: UILabel!
    @IBOutlet weak var storiesLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var followinfLabel: UILabel!
    @IBOutlet weak var followersNumberLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var delegate: FollowingListDelegate! = nil
    
    @IBAction func followingTapped(sender: UIButton) {
        self.delegate?.followingTapped()
    }
    
    @IBAction func followersTapped(sender: UIButton) {
        self.delegate?.followersTapped()
    }
}

protocol FollowingListDelegate {
    func followingTapped()
    func followersTapped()
}