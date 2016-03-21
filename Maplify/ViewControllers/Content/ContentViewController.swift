//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps

class ContentViewController: ViewController, StoryPointCreationPopupDelegate {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var createStoryPointButton: UIButton!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
    }
    
    // MARK: - setup
    func setupMap() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> Void in
            let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self!.mapView.service = GoogleMapService(region: region, zoom: 6)
            self!.mapView.service.setMapType(kGMSTypeNormal)
        }
    }
    
    // MARK: - actions
    @IBAction func createStoryPointTapped(sender: UIButton) {
        self.routesShowPopupStoryPointCreationController(self)
    }
    
    // MARK: - storyPointCreationPopupDelegate
    func ambientDidTapped() {
        
    }
    
    func photoVideoDidTapped() {
        
    }
    
    func textDidTapped() {
        
    }
}