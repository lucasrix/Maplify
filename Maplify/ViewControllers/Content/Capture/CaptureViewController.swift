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
import RealmSwift

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
let kPinWidthOffset: CGFloat = 8
let kPinHeightOffset: CGFloat = 25
let kDetailViewYOffset: CGFloat = 10

enum ContentType: Int {
    case Default
    case StoryPoint
    case Story
}

class CaptureViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var mapView: MCMapView!
    @IBOutlet weak var pressAndHoldLabel: UILabel!
    @IBOutlet weak var pressAndHoldView: UIView!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var addStoryButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var infiniteScrollView: InfiniteScrollView!
    @IBOutlet weak var infiniteScrollViewTopConstraint: NSLayoutConstraint!
    
    var addStoryPointButtonTapped: ((location: MCMapCoordinate, locationString: String) -> ())! = nil
    var googleMapService: GoogleMapService! = nil
    var captureDataSource: MCMapDataSource! = nil
    var captureActiveModel = MCMapActiveModel()
    var placeSearchHelper: GooglePlaceSearchHelper! = nil
    var userLastStoryPoint: StoryPoint! = nil
    var previewPlaceItem: MCMapItem! = nil
    var popTip: AMPopTip! = nil
    var locationString = String()
    
    var contentType: ContentType = .Default
    var currentStory: Story! = nil
    var currentStoryPoints = [StoryPoint]()
    var selectedStoryPointId: Int = 0
    var selectedStoryId: Int = 0
    var poppingControllerSupport: Bool = false
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.removePreviewItem()
    }
    
    // MARK: - setup
    func setup() {
        self.setupUI()
        self.checkLocationEnabled { [weak self] () in
            self?.updateData()
        }
    }
    
    func setupUI() {
        self.setupPlaceSearchHelper()
        self.setupPressAndHoldViewIfNeeded()
        self.setupBottomButtonIfNeeded()
        self.setupInfiniteScrollView()
        self.setupPopTip()
    }
    
    func setupTopBar() {
        self.setupNavigationBar()
        self.setupTitle()
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkBlueGrey().colorWithAlphaComponent(NavigationBar.defaultOpacity)
    }
    
    func loadData() {
        self.captureActiveModel.removeData()
        self.fetchData()
        self.configureActiveModel()
        self.drawMapData()
        self.updateInfiniteScrollIfNeeded()
        self.setupTopBar()
        self.showSelectedPostIfNeeded()
    }
    
    func updateData() {
        switch self.contentType {
        case .StoryPoint:
            self.loadRemoteStoryPont(self.selectedStoryPointId, completion: { [weak self] (success) in
                if success {
                    self?.loadData()
                }
            })
            
        case .Story:
            self.loadRemoteStory(self.selectedStoryId, completion: { [weak self] (success) in
                if success {
                    self?.loadData()
                }
            })
            
        default:
            self.loadLocalAllStoryPonts()
            self.loadRemoteAllStoryPonts({ [weak self] (success) in
                if success {
                    self?.loadData()
                }
            })
        }
    }
    
    func fetchData() {
        switch self.contentType {
        case .StoryPoint:
            self.loadLocalCurrentStoryPont(self.selectedStoryPointId)
            
        case .Story:
            self.loadLocalCurrentStory(self.selectedStoryId)
            
        default:
            self.loadLocalAllStoryPonts()
        }
    }
    
    func configureActiveModel() {
        switch self.contentType {
        case .Story:
            self.captureActiveModel.addItem(self.currentStory, section: 0, cellIdentifier: String(), sectionTitle: nil, delegate: self)
            self.captureActiveModel.addItems(self.currentStoryPoints, section: 0, cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self, boundingSize: CGSizeZero)
        default:
            self.captureActiveModel.addItems(self.currentStoryPoints, cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
        }
    }
    
    func drawMapData() {
        self.captureDataSource = MCMapDataSource()
        self.captureDataSource.mapActiveModel = self.captureActiveModel
        self.captureDataSource.mapView = self.mapView
        self.captureDataSource.mapService = self.googleMapService
        self.captureDataSource.reloadMapView(StoryPointMapItem)
    }
    
    // MARK: - actions
    @IBAction func notificationsTapped(sender: UIButton) {
        self.routesOpenNotificationsController()
    }
    
    @IBAction func addStoryTapped(sender: UIButton) {
        self.routesOpenStoryCreateController { [weak self] (storyId) in
            self?.contentType = .Story
            self?.selectedStoryId = storyId
            self?.loadData()
            self?.navigationController?.popToViewController(self!, animated: true)
            self?.showSelectedPostIfNeeded()
        }
    }
    
    @IBAction func profileTapped(sender: UIButton) {
        let userId = SessionManager.currentUser().id
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

