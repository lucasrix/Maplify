//
//  DiscoverChangeLocationPopupViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DiscoverChangeLocationPopupViewController: ViewController {
    var delegate: DiscoverChangeLocationDelegate! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupNavigationBarButtonItems()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.DiscoverChangeLocation", comment: String())
        
        // add shadow
        self.navigationController?.navigationBar.layer.shadowOpacity = kDiscoverNavigationBarShadowOpacity;
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeZero;
        self.navigationController?.navigationBar.layer.shadowRadius = kDiscoverNavigationBarShadowRadius;
        self.navigationController?.navigationBar.layer.masksToBounds = false;
    }
    
    func setupNavigationBarButtonItems() {
        self.addRightBarItem(NSLocalizedString("Button.Cancel", comment: String()))
    }
    
    // MARK: - navigation bar
    override func backButtonHidden() -> Bool {
        return true
    }
    
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - bur button items actions
    override func rightBarButtonItemDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol DiscoverChangeLocationDelegate {
    // TODO:
}
