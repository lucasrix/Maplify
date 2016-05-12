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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    var showingListOption: ShowingListOption = ShowingListOption.Followers
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupSegmentControl()
        self.setupTitle()
    }
    
    func setupSegmentControl() {
        self.segmentControl.setTitle(NSLocalizedString("Label.Followers", comment: String()).capitalizedString, forSegmentAtIndex: ShowingListOption.Followers.rawValue)
        self.segmentControl.setTitle(NSLocalizedString("Label.Following", comment: String()).capitalizedString, forSegmentAtIndex: ShowingListOption.Following.rawValue)
        self.segmentControl.selectedSegmentIndex = self.showingListOption.rawValue
    }
    
    func setupTitle() {
        if self.showingListOption == ShowingListOption.Followers {
            self.title = NSLocalizedString("Label.Followers", comment: String()).capitalizedString
        } else if self.showingListOption == ShowingListOption.Following {
            self.title = NSLocalizedString("Label.Following", comment: String()).capitalizedString
        }
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    @IBAction func segmentControlChangedValue(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == ShowingListOption.Followers.rawValue {
            self.showingListOption = ShowingListOption.Followers
        } else if sender.selectedSegmentIndex == ShowingListOption.Following.rawValue {
            self.showingListOption = ShowingListOption.Following
        }
        self.setupTitle()
    }
}
