//
//  FollowersViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class FollowersViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
}
