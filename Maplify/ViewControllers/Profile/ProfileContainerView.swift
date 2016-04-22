//
//  ProfileContainerView.swift
//  Maplify
//
//  Created by Sergei on 22/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class ProfileContainerView: UIView {
    private var profileViewController: ProfileViewController! = nil
    
    func configure(profileViewController: ProfileViewController) {
        self.profileViewController = profileViewController
    }
    
    func childView() -> UIView! {
        return (self.profileViewController != nil) ? self.profileViewController.view : nil
    }
    
    func contentHeight() -> CGFloat {
        return (self.profileViewController != nil) ? self.profileViewController.contentHeight() : 0
    }
}

