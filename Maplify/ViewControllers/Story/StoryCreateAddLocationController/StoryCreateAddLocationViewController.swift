//
//  StoryCreateAddLocationViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/13/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps
import UIKit

typealias SearchLocationClosure = ((place: GMSPlace) -> ())!

class StoryCreateAddLocationViewController: ViewController, GooglePlaceSearchHelperDelegate {
    
    var placeSearchHelper: GooglePlaceSearchHelper! = nil
    var searchLocationClosure: SearchLocationClosure! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupSearchController()
        self.setupNavigationBarItems()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    func setupSearchController() {
        self.placeSearchHelper = GooglePlaceSearchHelper(parentViewController: self)
        self.placeSearchHelper.delegate = self
        self.placeSearchHelper.showGooglePlaceSearchController()
    }
    
    func setupNavigationBarItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoSearch)!, target: self, action: #selector(StoryCreateAddLocationViewController.searchBarButtonHandler))
    }
    
    // MARK: - actions
    func searchBarButtonHandler() {
        if self.placeSearchHelper.controllerVisible {
            self.placeSearchHelper.hideGooglePlaceSearchController()
        } else {
            self.placeSearchHelper.showGooglePlaceSearchController()
        }
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return true
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK - GooglePlaceSearchHelperDelegate
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: error.description, cancel: cancel)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.searchLocationClosure?(place: place)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: error.description, cancel: cancel)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.placeSearchHelper.hideGooglePlaceSearchController()
    }
}
