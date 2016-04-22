//
//  DiscoverChangeLocationPopupViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import CoreLocation

class DiscoverChangeLocationPopupViewController: ViewController {
    @IBOutlet weak var allOverTheWorldButton: UIButton!
    @IBOutlet weak var nearMeButton: UIButton!
    
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
        self.setupButtons()
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
    
    func setupButtons() {
        self.allOverTheWorldButton.setTitle(NSLocalizedString("Button.AllOverTheWorld", comment: String()), forState: .Normal)
        self.nearMeButton.setTitle(NSLocalizedString("Button.NearMe", comment: String()), forState: .Normal)
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
    
    // MARK: - actions
    @IBAction func allOverTheWorldTapped(sender: UIButton) {
        self.delegate?.didSelectAllOverTheWorldLocation()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nearMeTapped(sender: UIButton) {
        self.delegate?.didSelectNearMePosition()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol DiscoverChangeLocationDelegate {
    func didSelectAllOverTheWorldLocation()
    func didSelectNearMePosition()
    func didSelectChoosenPlace(coordinates: CLLocationCoordinate2D, placeName: String)
}
