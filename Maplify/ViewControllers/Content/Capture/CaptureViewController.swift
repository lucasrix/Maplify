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
let kStoryPointsRequestSuspendInterval: NSTimeInterval = 2

class CaptureViewController: ViewController, MCMapServiceDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var addStoryPointImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var addStoryPointButtonTapped: ((location: MCMapCoordinate) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel: CSActiveModel! = nil
    var suspender = Suspender()
    
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
                self?.googleMapService = GoogleMapService(region: region, zoom: 6)
                self?.googleMapService.setMapType(kGMSTypeNormal)
                self?.googleMapService.delegate = self
                self?.mapView.service = self?.googleMapService
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
    
    // MARK: - request
    func retrieveStoryPoints(location: MCMapCoordinate, radius: CGFloat) {
        let locationDict: [String: AnyObject] = ["latitude": CGFloat(location.latitude), "longitude": CGFloat(location.longitude)]
        let params: [String: AnyObject] = ["location":locationDict, "radius": radius]
        ApiClient.sharedClient.getStoryPoints(params,
            success: { [weak self] (response) in
                print(response)
                print(self)
            },
            failure:  { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    // MARK: - MCMapServiceDelegate
    func willMoveMapView(mapView: UIView, willMove: Bool) {
        self.suspender.suspendEvent()
    }
    
    func didMoveMapView(mapView: UIView, target: AnyObject) {
        let clLocation = (target as! GMSCameraPosition).target
        let location = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
        self.suspender.executeEvent(kStoryPointsRequestSuspendInterval) { [weak self] () in
            print("request")
            self!.retrieveStoryPoints(location, radius: 1)
        }
    }
    
    // MARK: - actions
    func addStoryPointImageDidTap(touchGesture: UITapGestureRecognizer) {
        let point = touchGesture.locationInView(self.mapView)
        let location = self.googleMapService.locationFromTouch(self.mapView, point: point)
        self.addStoryPointButtonTapped(location: location)
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

