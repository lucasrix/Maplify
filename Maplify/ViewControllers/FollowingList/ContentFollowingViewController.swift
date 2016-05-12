//
//  ContentFollowingViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

enum ShowingListOption: Int {
    case Followers
    case Following
}

class ContentFollowingViewController: ViewController {
    
    var showingListOption: ShowingListOption = ShowingListOption.Followers

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
