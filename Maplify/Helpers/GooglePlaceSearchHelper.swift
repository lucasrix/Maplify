//
//  GooglePlaceSearchHelper.swift
//  Maplify
//
//  Created by Sergei on 11/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

@objc protocol GooglePlaceSearchHelperDelegate {
    optional func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace)
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError)
    optional func wasCancelled(viewController: GMSAutocompleteViewController)
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace)
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError)
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
}

class GooglePlaceSearchHelper: NSObject, GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate, UISearchBarDelegate {
    var resultsViewController = GMSAutocompleteResultsViewController()
    var searchController: UISearchController! = nil
    var controllerVisible: Bool = false
    var delegate: GooglePlaceSearchHelperDelegate! = nil
    private var parentViewController: UIViewController! = nil
    private var parentView: UIView! = nil
    
    // MARK: - init
    init(parentViewController: UIViewController) {
        super.init()
        self.setup(parentViewController)
    }
    
    // MARK: - setup
    private func setup(parentViewController: UIViewController) {
        self.setupResultsViewController()
        self.setupSearchController()
        self.placeSearchView(parentViewController)
    }
    
    func setupResultsViewController() {
        self.resultsViewController = GMSAutocompleteResultsViewController()
        self.resultsViewController.delegate = self
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: self.resultsViewController)
        self.searchController.searchResultsUpdater = self.resultsViewController
        self.searchController.searchBar.barTintColor = UIColor.darkGreyBlue()
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchBar.alpha = NavigationBar.defaultSearchBarOpacity
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.hidesNavigationBarDuringPresentation = false
    }
    
    func placeSearchView(parentViewController: UIViewController) {
        self.parentView = UIView(frame: CGRectMake(0, NavigationBar.defaultHeight, parentViewController.view.frame.size.width, SearchBar.defaultHeight))
        self.parentView.addSubview((self.searchController?.searchBar)!)
        parentViewController.view.addSubview(self.parentView)
        parentViewController.definesPresentationContext = true
        self.parentView.hidden = true
    }
    
    // MARK: - actions
    func showGooglePlaceSearchController() {
        if self.controllerVisible == false {
            self.controllerVisible = true
            self.parentView.hidden = false
        }
    }
    
    func hideGooglePlaceSearchController() {
        if self.controllerVisible == true {
            self.controllerVisible = false
            self.parentView.hidden = true
        }
    }
    
    // MARK: - GMSAutocompleteViewControllerDelegate
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.delegate?.viewController?(viewController, didAutocompleteWithPlace: place)
    }

    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        self.delegate?.viewController(viewController, didFailAutocompleteWithError: error)
    }

    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.delegate?.wasCancelled?(viewController)
    }
    
    // MARK: - GMSAutocompleteResultsViewControllerDelegate
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.delegate?.resultsController(resultsViewController, didAutocompleteWithPlace: place)
    }
   
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError) {
        self.delegate?.resultsController(resultsViewController, didFailAutocompleteWithError: error)
    }
    
    // MARK - UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.delegate?.searchBarCancelButtonClicked(searchBar)
    }
}
