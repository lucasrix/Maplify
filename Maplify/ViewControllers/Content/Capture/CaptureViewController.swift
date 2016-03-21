//
//  CaptureViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps

let kMinimumPressDuration: NSTimeInterval = 1

class CaptureViewController: ViewController {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var addStoryPointImageView: UIImageView!
    
    var addStoryPointButtonTapped: (() -> ())! = nil

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupMap()
        self.setupAddStoryPointImageView()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }

    func setupMap() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
            let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self!.mapView.service = GoogleMapService(region: region, zoom: 6)
            self!.mapView.service.setMapType(kGMSTypeNormal)
        }
    }
    
    func setupAddStoryPointImageView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: "addStoryPointImageDidTap")
        gesture.minimumPressDuration = kMinimumPressDuration
        self.addStoryPointImageView.addGestureRecognizer(gesture)
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkBlueGrey().colorWithAlphaComponent(NavigationBar.defaultOpacity)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    @IBAction func addStoryPointImageDidTap() {
        self.addStoryPointButtonTapped()
    }
}

