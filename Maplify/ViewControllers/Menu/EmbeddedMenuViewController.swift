//
//  EmbeddedMenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class EmbeddedMenuViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.tableView.separatorColor = UIColor.darkGreyBlue()
    }
}
