//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

class ContentViewController: ViewController {
    @IBOutlet weak var mapView: MCMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //test map classes
//        let region = MCMapRegion(latitude: -33.8683, longitude: 151.2086)
//        self.mapView.service = GoogleMapService(region: region, zoom: 6)
//        self.mapView.service.setMapType(kGMSTypeNormal)
//        
//        let pinLocation = MCMapCoordinate(latitude: -33.8683, longitude: 151.2086)
//        let pin = MCMapItem(location: pinLocation, title: "Test pin", image: nil)
//        
//        let pinLocation2 = MCMapCoordinate(latitude: -35.8683, longitude: 148.2086)
//        let pin2 = MCMapItem(location: pinLocation2, title: "Test pin", image: nil)
//        
//        self.mapView.service.placeItem(pin)
//        self.mapView.service.placeItem(pin2)        
    }
}