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
let kMinimumLineSpacing: CGFloat = 0.001

class CaptureViewController: ViewController {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var addStoryPointImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var addStoryPointButtonTapped: ((location: MCMapCoordinate) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel: CSActiveModel! = nil
    
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
        self.setupStoryPointDetails()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }

    func setupMap() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
            if location != nil {
                let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self!.mapView.service = GoogleMapService(region: region, zoom: 6)
                self!.mapView.service.setMapType(kGMSTypeNormal)
            }
        }
    }
    
    func setupAddStoryPointImageView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: "addStoryPointImageDidTap:")
        gesture.minimumPressDuration = kMinimumPressDuration
        self.addStoryPointImageView.addGestureRecognizer(gesture)
    }
    
    func setupStoryPointDetails() {
        self.storyPointActiveModel = CSActiveModel()
        self.storyPointActiveModel.addItems(["1", "2", "3"], cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
        self.storyPointDataSource = StoryPointDataSource(collectionView: self.collectionView, activeModel: self.storyPointActiveModel, delegate: self)
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = kMinimumLineSpacing
        self.collectionView.layoutIfNeeded()
        self.storyPointDataSource.reloadCollectionView()
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkBlueGrey().colorWithAlphaComponent(NavigationBar.defaultOpacity)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    func addStoryPointImageDidTap(touchGesture: UITapGestureRecognizer) {
        let point = touchGesture.locationInView(self.mapView)
        let location = self.googleMapService.locationFromTouch(self.mapView, point: point)
        self.addStoryPointButtonTapped(location: location)
    }
}

