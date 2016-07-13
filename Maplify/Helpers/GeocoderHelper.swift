//
//  GeocoderHelper.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

class GeocoderHelper {
    class func placeFromCoordinate(coordinate: CLLocationCoordinate2D, completion: ((addressString: String) -> ())!) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (response, error) in
            if error == nil {
                let address = response?.firstResult()
                var addressString = String()
                if address?.thoroughfare != nil {
                    addressString = (address?.thoroughfare)!
                } else if address?.locality != nil {
                    addressString = (address?.locality)!
                } else {
                    addressString = (GeocoderHelper.generateLocationString(coordinate))
                }
                completion(addressString: addressString)
            } else {
                let addressString = (GeocoderHelper.generateLocationString(coordinate))
                completion(addressString: addressString)
            }
        })
    }
    
    class func generateLocationString(coordinate: CLLocationCoordinate2D!) -> String {
        return String(format: NSLocalizedString("Label.LatitudeLongitude", comment: String()), coordinate.latitude, coordinate.longitude)
    }
}
