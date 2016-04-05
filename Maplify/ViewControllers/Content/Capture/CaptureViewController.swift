//
//  CaptureViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps
import RealmSwift

let kMinimumPressDuration: NSTimeInterval = 1
let kMinimumLineSpacing: CGFloat = 0.001
let kStoryPointsRequestSuspendInterval: NSTimeInterval = 2
let kStoryPointsFindingRadius: CGFloat = 10
let kDefaulMapZoom: Float = 13

class CaptureViewController: ViewController, MCMapServiceDelegate, CSBaseCollectionDataSourceDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var addStoryPointImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var addStoryPointButtonTapped: ((location: MCMapCoordinate) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var suspender = Suspender()
    
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    
    var mapActiveModel = MCMapActiveModel()
    var mapDataSource: MCMapDataSource! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.checkLocationEnabled()
        self.loadItemsFromDB()
        self.setupAddStoryPointImageView()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    func setupMapDataSource() {
        self.mapDataSource = MCMapDataSource()
        self.mapDataSource.mapActiveModel = self.mapActiveModel
        self.mapDataSource.mapView = self.mapView
        self.mapDataSource.mapService = self.googleMapService
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }

    func checkLocationEnabled() {
        if SessionHelper.sharedManager.locationEnabled() {
            INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
                if location != nil {
                    self?.setupMap(location)
                }
            }
        } else {
            self.setupMap(CLLocation(latitude: DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1))
        }
        
    }
    
    func setupMap(location: CLLocation) {
        let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.googleMapService = GoogleMapService(region: region, zoom: kDefaulMapZoom)
        self.googleMapService.setMapType(kGMSTypeNormal)
        self.googleMapService.delegate = self
        self.mapView.service = self.googleMapService
    }
    
    func setupAddStoryPointImageView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(CaptureViewController.addStoryPointImageDidTap(_:)))
        gesture.minimumPressDuration = kMinimumPressDuration
        self.addStoryPointImageView.addGestureRecognizer(gesture)
    }
    
    func updateStoryPointDetails(storyPoints: [StoryPoint]) {
        self.storyPointActiveModel.removeData()
        self.storyPointActiveModel.addItems(storyPoints, cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
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
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        let storyPoints = Array(realm.objects(StoryPoint))
        self.updateStoryPointDetails(storyPoints)
        self.updateMapActiveModel(storyPoints)
        self.setupMapDataSource()
    }
    
    func updateMapActiveModel(storyPoints: [StoryPoint]) {
        self.mapActiveModel.removeData()
        self.mapActiveModel.addItems(storyPoints)
    }
    
    // MARK: - request
    func retrieveStoryPoints(location: MCMapCoordinate, radius: CGFloat) {
        let locationDict: [String: AnyObject] = ["latitude": CGFloat(location.latitude), "longitude": CGFloat(location.longitude)]
        let params: [String: AnyObject] = ["location":locationDict, "radius": radius]
        ApiClient.sharedClient.getStoryPoints(params,
            success: { [weak self] (response) in
                if let storyPoints = response {
                    StoryPointManager.saveStoryPoints(storyPoints as! [StoryPoint])
                    self?.loadItemsFromDB()
                }
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    // MARK: - actions
    func addStoryPointImageDidTap(touchGesture: UITapGestureRecognizer) {
        let point = touchGesture.locationInView(self.mapView)
        let location = self.googleMapService.locationFromTouch(self.mapView, point: point)
        self.addStoryPointButtonTapped(location: location)
    }
    
    // MARK: - MCMapServiceDelegate
    func willMoveMapView(mapView: UIView, willMove: Bool) {
        self.suspender.suspendEvent()
    }
    
    func didMoveMapView(mapView: UIView, target: AnyObject) {
        let clLocation = (target as! GMSCameraPosition).target
        let location = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
        self.suspender.executeEvent(kStoryPointsRequestSuspendInterval) { [weak self] () in
            self?.retrieveStoryPoints(location, radius: kStoryPointsFindingRadius)
        }
    }
    
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        let clLocation = (itemObject as! GMSMarker).position
        let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
        let storyPointIndex = self.mapActiveModel.storyPointIndex(mapCoordinate, section: 0)
        if storyPointIndex != NSNotFound {
            let indexPath = NSIndexPath(forRow: storyPointIndex, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            let region = MCMapRegion(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
        }
    }
    
    // MARK: - CSBaseCollectionDataSourceDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = NSIndexPath(forRow: currentIndex, inSection: 0)
        let storyPoint = self.mapActiveModel.storyPoint(indexPath)
        
        let region = MCMapRegion(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
        self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

