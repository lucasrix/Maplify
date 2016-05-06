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
    var publicStoryPointsSupport: Bool = false
    var publicStory: Story! = nil
    
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
        if self.publicStoryPointsSupport == false {
            self.pressAndHoldView.layer.cornerRadius = CGRectGetHeight(self.pressAndHoldView.frame) / 2
            self.pressAndHoldLabel.text = NSLocalizedString("Label.PressAndHold", comment: String())
        }
        self.pressAndHoldView.hidden = self.publicStoryPointsSupport
    }
    
    func setupCollectionView() {
        self.collectionView.hidden = true
    }
    
    func setupPlaceSearchHelper() {
        self.placeSearchHelper = GooglePlaceSearchHelper(parentViewController: self)
        self.placeSearchHelper.delegate = self
    }
    
    func setupNavigationBar() {
        if self.publicStoryPointsSupport {
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
        self.title = self.publicStory.title
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
        if SessionHelper.sharedHelper.locationEnabled() && self.publicStoryPointsSupport == false {
            INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
                if location != nil {
                    SessionHelper.sharedHelper.updateUserLastLocationIfNeeded(location)
                    self?.setupMap(location)
                } else {
                    self?.setupMap(SessionHelper.sharedHelper.userLastLocation())
                }
            }
        }
    }
    
    func setupMap(location: CLLocation) {
        let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.googleMapService = GoogleMapService(region: region, zoom: kDefaulMapZoom)
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
        if self.publicStoryPointsSupport {
            return UIColor.grapePurple().colorWithAlphaComponent(NavigationBar.captureStoryMapOpacity)
        }
        return UIColor.darkBlueGrey().colorWithAlphaComponent(NavigationBar.defaultOpacity)
    }
    
    func loadItemsFromDBIfNedded() {
        var storyPoints: [StoryPoint]! = nil
        if self.publicStoryPointsSupport {
            storyPoints = Converter.listToArray(self.publicStory.storyPoints, type: StoryPoint.self)
            let location = storyPoints.first?.location
            self.setupMap(CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!))

        } else {
            storyPoints = StoryPointManager.userStoryPoints("created_at", ascending: false)
        }
        
        self.updateStoryPointDetails(storyPoints)
        self.updateMapActiveModel(storyPoints)
        self.setupMapDataSource()
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
        if self.publicStoryPointsSupport == false {
            let locationDict: [String: AnyObject] = ["latitude": CGFloat(location.latitude), "longitude": CGFloat(location.longitude)]
            let params: [String: AnyObject] = ["location":locationDict, "radius": radius]
            ApiClient.sharedClient.getStoryPoints(params,
                                                  success: { [weak self] (response) in
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
    
    // MARK: - actions
    func locationButtonTapped() {
        self.googleMapService.moveToDefaultRegion()
    }
    
    func searchButtonTapped() {
        if self.placeSearchHelper.controllerVisible {
            self.placeSearchHelper.hideGooglePlaceSearchController()
        } else {
            self.placeSearchHelper.showGooglePlaceSearchController()
        }
    }
    
    func cancelButtonTapped() {
        self.popControllerFromLeft()
    }
    
    // MARK: - MCMapServiceDelegate
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        let clLocation = (itemObject as! GMSMarker).position
        let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
        let storyPointIndex = self.mapActiveModel.storyPointIndex(mapCoordinate, section: 0)
        
        if storyPointIndex != NSNotFound {
            let indexPath = NSIndexPath(forRow: storyPointIndex, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            let region = MCMapRegion(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            self.googleMapService.moveTo(region, zoom: self.googleMapService.currentZoom())
            
            self.mapActiveModel.selectPinAtIndex(storyPointIndex)
            self.mapDataSource.reloadMapView(StoryPointMapItem)
        }
        
        self.collectionView.hidden = false
    }
    
    func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double) {
        self.collectionView.hidden = true
        self.mapActiveModel.deselectAll()
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func didLongTapMapView(mapView: UIView, latitude: Double, longitude: Double) {
        if self.publicStoryPointsSupport == false {
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

