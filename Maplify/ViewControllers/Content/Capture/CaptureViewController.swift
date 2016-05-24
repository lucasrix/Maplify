//
//  CaptureViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps
import AMPopTip

let kMinimumPressDuration: NSTimeInterval = 1
let kMinimumLineSpacing: CGFloat = 0.001
let kStoryPointsRequestSuspendInterval: NSTimeInterval = 1
let kStoryPointsFindingRadius: CGFloat = 10000000
let kDefaulMapZoom: Float = 13
let kPinIconDeltaX: CGFloat = 4
let kPinIconDeltaY: CGFloat = 42
let kPoptipShadowOpacity: Float = 0.15
let kPoptipShadowRadius: CGFloat = 6
let kPoptipViewWidth: CGFloat = 290
let kPoptipViewHeight: CGFloat = 35
let kPoptipBorderWidth: CGFloat = 0
let kPoptipPopoverColorAlpha: CGFloat = 0.95
let kNotificationsButtonBackgroundColorAlpha: CGFloat = 0.4
let kAddStoryButtonBackgroundColorAlpha: CGFloat = 0.7

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
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var addStoryButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!

    var addStoryPointButtonTapped: ((location: MCMapCoordinate, locationString: String) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    var mapActiveModel = MCMapActiveModel()
    var mapDataSource: MCMapDataSource! = nil
    var placeSearchHelper: GooglePlaceSearchHelper! = nil
    var userLastStoryPoint: StoryPoint! = nil
    var contentType: ContentType = .Default
    var publicStoryPoints: [StoryPoint]! = []
    var publicTitle = String()
    var sharedType = String()
    var sharedId: Int = 0
    var previewPlaceItem: MCMapItem! = nil
    var popTip: AMPopTip! = nil
    var locationString = String()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupCollectionView()
        self.setupNavigationBar()
        self.setupBottomButtonIfNeeded()
        self.loadItemsFromDBIfNedded()
    }
    
    // MARK: - setup
    func setup() {
        self.setupPlaceSearchHelper()
        self.checkLocationEnabled()
        self.setupPopTip()
        self.setupPressAndHoldViewIfNeeded()
    }
    
    func setupPopTip() {
        let appearance = AMPopTip.appearance()
        appearance.popoverColor = UIColor.whiteColor().colorWithAlphaComponent(kPoptipPopoverColorAlpha)
        appearance.borderWidth = kPoptipBorderWidth
        appearance.rounded = true
    }
    
    func setupPressAndHoldViewIfNeeded() {
        if self.contentType == .Default {
            self.pressAndHoldView.layer.cornerRadius = CGRectGetHeight(self.pressAndHoldView.frame) / 2
            self.pressAndHoldLabel.text = NSLocalizedString("Label.PressAndHold", comment: String())
        }
        self.pressAndHoldView.hidden = self.contentType != .Default
    }
    
    func setupCollectionView() {
        self.collectionView.hidden = true
    }
    
    func setupPlaceSearchHelper() {
        self.placeSearchHelper = GooglePlaceSearchHelper(parentViewController: self)
        self.placeSearchHelper.delegate = self
    }
    
    func setupNavigationBar() {
        if (self.contentType != .Default) {
            self.setupStoryCaptureNavigationBar()
        } else {
            self.setupDefaultCaptureNavigationBar()
        }
    }
    
    func setupBottomButtonIfNeeded() {
        let cornerRadius = CGRectGetHeight(self.notificationsButton.frame) / 2
        
        self.notificationsButton.layer.cornerRadius = cornerRadius
        self.notificationsButton.backgroundColor = UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationsButtonBackgroundColorAlpha)
        
        self.addStoryButton.layer.cornerRadius = cornerRadius
        self.addStoryButton.backgroundColor = UIColor.darkGreyBlue().colorWithAlphaComponent(kAddStoryButtonBackgroundColorAlpha)
        self.addStoryButton.setTitle(NSLocalizedString("Label.Story", comment: String()).uppercaseString, forState: .Normal)
        
        self.profileButton.layer.cornerRadius = cornerRadius
        self.profileButton.backgroundColor = UIColor.darkGreyBlue().colorWithAlphaComponent(kNotificationsButtonBackgroundColorAlpha)
        
        self.notificationsButton.hidden = self.contentType != .Default
        self.addStoryButton.hidden = self.contentType != .Default
        self.profileButton.hidden = self.contentType != .Default
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
        if SessionHelper.sharedHelper.locationEnabled() && self.contentType == .Default {
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
        if self.contentType == .Default {
            storyPoints = StoryPointManager.allStoryPoints()
        } else if self.contentType == .Share {
            storyPoints = self.sharedType == SharingKeys.typeStoryPoint ? self.loadSharedStoryPoint() : self.loadSharedStory()
            self.publicStoryPoints = storyPoints
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
            self.title = storyPoint.caption
            return [storyPoint]
        }
        return []
    }
    
    func loadSharedStory() -> [StoryPoint] {
        if let story = StoryManager.find(self.sharedId) {
            self.title = story.title
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
        if self.contentType != .Default && self.publicStoryPoints.count > 0 {
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
        if self.contentType == .Default {
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
        else if self.contentType == .Share {
            self.retrieveSharedItem()
        }
    }
    
    func retrieveSharedItem() {
        if self.sharedType == SharingKeys.typeStoryPoint {
            self.retrieveSharedStoryPoint()
        } else if self.sharedType == SharingKeys.typeStory {
            self.retrieveSharedStory()
        }
    }
    
    func retrieveSharedStoryPoint() {
        ApiClient.sharedClient.getStoryPoint(self.sharedId, success: { [weak self] (response) in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            self?.loadItemsFromDBIfNedded()
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func retrieveSharedStory() {
        ApiClient.sharedClient.getStory(self.sharedId, success: { [weak self] (response) in
            StoryManager.saveStory(response as! Story)
            self?.loadItemsFromDBIfNedded()
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
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
        if self.contentType == .Notification {
            let title = NSLocalizedString("Alert.Info", comment: String())
            let message = NSLocalizedString("Alert.StoryDoesntHaveStoryPoints", comment: String())
            let cancel = NSLocalizedString("Button.Ok", comment: String())
            self.showMessageAlert(title, message: message, cancel: cancel)
        }
    }
    
    // MARK: - actions
    @IBAction func notificationsTapped(sender: UIButton) {
        self.routesOpenNotificationsController()
    }
    
    @IBAction func addStoryTapped(sender: UIButton) {
        self.routesOpenStoryCreateController { 
            // TODO:
        }
    }
    
    @IBAction func profileTapped(sender: UIButton) {
        let userId = SessionManager.currentUser().id
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
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
        if self.contentType == .Share {
            self.routesSetContentController()
        } else {
            self.popControllerFromLeft()
        }
    }
    
    func removePreviewItem() {
        if self.previewPlaceItem != nil {
            self.googleMapService.removeItem(self.previewPlaceItem)
            self.previewPlaceItem = nil
        }
        self.popTip?.hide()
    }
    
    // MARK: - MCMapServiceDelegate
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        if ((itemObject as! GMSMarker).userData as! Bool) == false {
            let clLocation = (itemObject as! GMSMarker).position
            let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
            let storyPointIndex = self.mapActiveModel.storyPointIndex(mapCoordinate, section: 0)
            
            self.selectPin(storyPointIndex, mapCoordinate: mapCoordinate)
            self.collectionView.hidden = false
        }
    }
    
    func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double) {
        self.collectionView.hidden = true
        self.removePreviewItem()
        self.mapActiveModel.deselectAll()
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func didLongTapMapView(mapView: UIView, latitude: Double, longitude: Double, locationInView: CGPoint) {
        if self.contentType == .Default {
            self.pressAndHoldView.hidden = true
            self.pressAndHoldLabel.hidden = true
            let coordinate = MCMapCoordinate(latitude: latitude, longitude: longitude)
            self.removePreviewItem()
            let placeItem = MCMapItem()
            placeItem.location = coordinate
            placeItem.image = UIImage(named: MapPinImages.tapped)
            
            self.previewPlaceItem = placeItem
            self.googleMapService.placeItem(placeItem, temporary: true)
            
            self.configuratePopup(locationInView, coordinate: coordinate)
        }
    }
    
    func configuratePopup(locationInView: CGPoint, coordinate: MCMapCoordinate) {
        let popupView = CapturePopUpView(frame: CGRect(x: 0, y: 0, width: kPoptipViewWidth, height: kPoptipViewHeight))
        popupView.configure(coordinate) { [weak self] (locationString) in
            self?.locationString = locationString
        }

        self.popTip = AMPopTip()
        self.popTip.layer.shadowColor = UIColor.blackColor().CGColor
        self.popTip.layer.shadowOpacity = kPoptipShadowOpacity
        self.popTip.layer.shadowOffset = CGSizeZero
        self.popTip.layer.shadowRadius = kPoptipShadowRadius
        self.popTip.tapHandler = { [weak self] () -> () in
            self?.routesOpenAddToStoryController([], storypointCreationSupport: true, pickedLocation: coordinate, locationString: (self?.locationString)!, updateStoryHandle: nil)
            self?.popTip?.hide()
            self?.removePreviewItem()
        }
        self.popTip.showCustomView(popupView, direction: .Up, inView: self.view, fromFrame: CGRectMake(locationInView.x - kPinIconDeltaX, locationInView.y - kPinIconDeltaY, 0, 0))
    }
    
    func willMoveMapView(mapView: UIView, willMove: Bool) {
        self.removePreviewItem()
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

