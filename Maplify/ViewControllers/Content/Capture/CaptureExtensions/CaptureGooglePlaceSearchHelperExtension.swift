//
//  CaptureGooglePlaceSearchHelperExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

extension CaptureViewController {
    
    // MARK - GooglePlaceSearchHelperDelegate
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: error.description, cancel: cancel)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        let region = MCMapRegion(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.placeSearchHelper.hideGooglePlaceSearchController()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
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
