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
let kStoryPointsRequestSuspendInterval: NSTimeInterval = 1
let kStoryPointsFindingRadius: CGFloat = 10000000
let kDefaulMapZoom: Float = 13

enum ContentType: Int {
    case Default
    case Profile
    case Notification
    case Share
}

class CaptureViewController: ViewController, MCMapServiceDelegate, CSBaseCollectionDataSourceDelegate, GooglePlaceSearchHelperDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pressAndHoldLabel: UILabel!
    @IBOutlet weak var pressAndHoldView: UIView!

    var addStoryPointButtonTapped: ((location: MCMapCoordinate) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    var mapActiveModel = MCMapActiveModel()
    var mapDataSource: MCMapDataSource! = nil
    var placeSearchHelper: GooglePlaceSearchHelper! = nil
    var userLastStoryPoint: StoryPoint! = nil
    var contentType: ContentType = ContentType.Default
    var publicStoryPoints: [StoryPoint]! = []
    var publicTitle = String()
    var sharedType = String()
    var sharedId: Int = 0
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupCollectionView()
        self.setupNavigationBar()
        self.loadItemsFromDBIfNedded()
    }
    
    // MARK: - setup
    func setup() {
        self.setupPlaceSearchHelper()
        self.checkLocationEnabled()
        self.setupPressAndHoldViewIfNeeded()
    }
    
    func setupPressAndHoldViewIfNeeded() {
        if self.contentType == ContentType.Default {
            self.pressAndHoldView.layer.cornerRadius = CGRectGetHeight(self.pressAndHoldView.frame) / 2
            self.pressAndHoldLabel.text = NSLocalizedString("Label.PressAndHold", comment: String())
        }
        self.pressAndHoldView.hidden = self.contentType != ContentType.Default
    }
    
    func setupCollectionView() {
        self.collectionView.hidden = true
    }
    
    func setupPlaceSearchHelper() {
        self.placeSearchHelper = GooglePlaceSearchHelper(parentViewController: self)
        self.placeSearchHelper.delegate = self
    }
    
    func setupNavigationBar() {
        if (self.contentType != ContentType.Default) {
            self.setupStoryCaptureNavigationBar()
        } else {
            self.setupDefaultCaptureNavigationBar()
        }
    }
    
    func setupDefaultCaptureNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoGps)!, target: self, action: #selector(CaptureViewController.locationButtonTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoSearch)!, target: self, action: #selector(CaptureViewController.searchButtonTapped))
    }
    
    func setupStoryCaptureNavigationBar() {
        self.title = self.publicTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(CaptureViewController.cancelButtonTapped))
    }
    
    func setupMapDataSource() {
        self.mapDataSource = MCMapDataSource()
        self.mapDataSource.mapActiveModel = self.mapActiveModel
        self.mapDataSource.mapView = self.mapView
        self.mapDataSource.mapService = self.googleMapService
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func checkLocationEnabled() {
        if SessionHelper.sharedHelper.locationEnabled() && self.contentType == ContentType.Default {
            self.retrieveCurrentLocation({ [weak self] (location) in
                if location != nil {
                    SessionHelper.sharedHelper.updateUserLastLocationIfNeeded(location)
                    self?.setupMap(location, showWholeWorld: false)
                } else {
                    self?.setupMap(SessionHelper.sharedHelper.userLastLocation(), showWholeWorld: true)
                }
            })
        } else {
            let defaultLocation = CLLocation(latitude: DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
            self.setupMap(defaultLocation, showWholeWorld: true)
        }
    }
    
    func retrieveCurrentLocation(completion: ((location: CLLocation!) -> ())!) {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { (location, accuracy, status) -> () in
            completion(location: location)
        }
    }
    
    func setupMap(location: CLLocation, showWholeWorld: Bool) {
        let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.googleMapService = GoogleMapService(region: region, zoom: kDefaulMapZoom, showWholeWorld: showWholeWorld)
        self.googleMapService.setMapType(kGMSTypeNormal)
        self.googleMapService.delegate = self
        self.mapView.service = self.googleMapService
    
        self.loadDataFromRemote()
    }
    
    func updateStoryPointDetails(storyPoints: [StoryPoint]) {
        self.storyPointActiveModel.removeData()
        self.storyPointActiveModel.addItems(storyPoints, cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
        self.storyPointDataSource = StoryPointDataSource(collectionView: self.collectionView, activeModel: self.storyPointActiveModel, delegate: self)
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = kMinimumLineSpacing
        self.storyPointDataSource.reloadCollectionView()
    }
    
    // MARK: - navigation bar
    override func navigationBarColor() -> UIColor {
        return UIColor.darkBlueGrey().colorWithAlphaComponent(NavigationBar.defaultOpacity)
    }
    
    func loadItemsFromDBIfNedded() {
        var storyPoints: [StoryPoint]! = []
        if self.contentType == ContentType.Default {
            storyPoints = StoryPointManager.allStoryPoints()
        } else if self.contentType == ContentType.Share {
            storyPoints = self.sharedType == SharingKeys.typeStoryPoint ? self.loadSharedStoryPoint() : self.loadSharedStory()
        } else {
            storyPoints = self.publicStoryPoints
            self.setupPublicMap()
        }
        
        self.updateStoryPointDetails(storyPoints)
        self.updateMapActiveModel(storyPoints)
        self.setupMapDataSource()
        self.setupCollectionViewIfNeeded()
    }
    
    func loadSharedStoryPoint() -> [StoryPoint] {
        if let storyPoint = StoryPointManager.find(self.sharedId) {
            return [storyPoint]
        }
        return []
    }
    
    func loadSharedStory() -> [StoryPoint] {
        if let story = StoryManager.find(self.sharedId) {
            return Converter.listToArray(story.storyPoints, type: StoryPoint.self)
        }
        return []
    }
    
    func setupPublicMap() {
        var location: CLLocation! = nil
        if self.publicStoryPoints.count > 0 {
            let storyPointLocation = self.publicStoryPoints.first!.location
            location = CLLocation(latitude: storyPointLocation.latitude, longitude: storyPointLocation.longitude)
        } else {
            location = CLLocation(latitude: DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
            self.showEmptyStoryErrorIfNeeded()
        }
        let showWholeWorld = self.publicStoryPoints.count == 0
        self.setupMap(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), showWholeWorld: showWholeWorld)
    }
    
    func selectPin(index: Int, mapCoordinate: MCMapCoordinate) {
        if index != NSNotFound {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            let region = MCMapRegion(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
            
            self.mapActiveModel.selectPinAtIndex(index)
            self.mapDataSource.reloadMapView(StoryPointMapItem)
        }
    }
    
    func setupCollectionViewIfNeeded() {
        if self.contentType != ContentType.Default && self.publicStoryPoints.count > 0 {
            let location = self.publicStoryPoints.first?.location
            let mapCoordinate = MCMapCoordinate(latitude: location!.latitude, longitude: location!.longitude)
            self.selectPin(0, mapCoordinate: mapCoordinate)
            self.collectionView.hidden = false
        }
    }
    
    func loadDataFromRemote() {
        let clLocation = SessionHelper.sharedHelper.userLastLocation()
        let location = MCMapCoordinate(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
        self.retrieveStoryPointsIfNeeded(location, radius: kStoryPointsFindingRadius)
    }
    
    func updateMapActiveModel(storyPoints: [StoryPoint]) {
        self.mapActiveModel.removeData()
        self.mapActiveModel.addItems(storyPoints)
    }
    
    // MARK: - request
    func retrieveStoryPointsIfNeeded(location: MCMapCoordinate, radius: CGFloat) {
        if self.contentType == ContentType.Default {
            ApiClient.sharedClient.getAllStoryPoints({ [weak self] (response) in
                                                    if let storyPoints = response {
                                                        StoryPointManager.saveStoryPoints(storyPoints as! [StoryPoint])
                                                        self?.loadItemsFromDBIfNedded()
                                                        self?.movetoLastStoryPointIfNeeded()
                                                    }
                },
                                                  failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                }
            )
        }
        else if self.contentType == ContentType.Share {
            print("share")
        }
    }
    
    func movetoLastStoryPointIfNeeded() {
        let storyPoints = StoryPointManager.userStoryPoints("created_at", ascending: false)
        if (self.userLastStoryPoint == nil) && (storyPoints.count > 0) {
            self.userLastStoryPoint = storyPoints.first
            let location = self.userLastStoryPoint.location
            let region = MCMapRegion(latitude: location.latitude, longitude: location.longitude)
            self.googleMapService?.moveTo(region, zoom: (self.googleMapService?.currentZoom())!)
        }
    }
    
    func showEmptyStoryErrorIfNeeded() {
        if self.contentType == ContentType.Notification {
            let title = NSLocalizedString("Alert.Info", comment: String())
            let message = NSLocalizedString("Alert.StoryDoesntHaveStoryPoints", comment: String())
            let cancel = NSLocalizedString("Button.Ok", comment: String())
            self.showMessageAlert(title, message: message, cancel: cancel)
        }
    }
    
    // MARK: - actions
    func locationButtonTapped() {
        self.retrieveCurrentLocation { [weak self] (location) in
            var region: MCMapRegion! = nil
            if location != nil {
                region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self?.googleMapService?.moveTo(region, zoom: (self?.googleMapService?.currentZoom())!)
            }
        }
    }
    
    func searchButtonTapped() {
        if self.placeSearchHelper.controllerVisible {
            self.placeSearchHelper.hideGooglePlaceSearchController()
        } else {
            self.placeSearchHelper.showGooglePlaceSearchController()
        }
    }
    
    func cancelButtonTapped() {
        if self.contentType == ContentType.Share {
            self.routesSetContentController()
        } else {
            self.popControllerFromLeft()
        }
    }
    
    // MARK: - MCMapServiceDelegate
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        let clLocation = (itemObject as! GMSMarker).position
        let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
        let storyPointIndex = self.mapActiveModel.storyPointIndex(mapCoordinate, section: 0)
        
        self.selectPin(storyPointIndex, mapCoordinate: mapCoordinate)
        self.collectionView.hidden = false
    }
    
    func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double) {
        self.collectionView.hidden = true
        self.mapActiveModel.deselectAll()
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func didLongTapMapView(mapView: UIView, latitude: Double, longitude: Double) {
        if self.contentType == ContentType.Default {
            self.pressAndHoldView.hidden = true
            self.pressAndHoldLabel.hidden = true
            let coordinate = MCMapCoordinate(latitude: latitude, longitude: longitude)
            self.addStoryPointButtonTapped(location: coordinate)
        }
    }
    
    // MARK: - CSBaseCollectionDataSourceDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = NSIndexPath(forRow: currentIndex, inSection: 0)
        
        self.mapActiveModel.selectPinAtIndex(currentIndex)
        self.mapDataSource.reloadMapView(StoryPointMapItem)
        
        let storyPoint = self.mapActiveModel.storyPoint(indexPath)
        
        let region = MCMapRegion(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
        self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
    }
    
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
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

