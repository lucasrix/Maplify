//
//  DiscoverViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import RealmSwift
import INSPullToRefresh.UIScrollView_INSPullToRefresh

let kDiscoverItemsInPage = 25
let kDiscoverFirstPage = 1

enum EditContentOption: Int {
    case EditPost
    case DeletePost
    case Directions
    case SharePost
}

enum DefaultContentOption: Int {
    case Directions
    case SharePost
    case ReportAbuse
}

enum RequestState: Int {
    case Ready
    case Loading
}

enum SearchLocationParameter: Int {
    case AllOverTheWorld
    case NearMe
    case ChoosenPlace
}

enum DiscoverItemSortParameter: String {
    case nearMe = "nearMePosition"
    case allOverTheWorld = "allOverTheWorldPosition"
    case choosenPlace = "choosenPlacePosition"
}

let kDiscoverNavigationBarShadowOpacity: Float = 0.8
let kDiscoverNavigationBarShadowRadius: CGFloat = 3
let kDiscoverSearchingRadius: CGFloat = 10000000

class DiscoverViewController: ViewController, CSBaseTableDataSourceDelegate, DiscoverStoryPointCellDelegate, DiscoverStoryCellDelegate, ErrorHandlingProtocol, DiscoverChangeLocationDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: DiscoverTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var discoverShowProfileClosure: ((userId: Int) -> ())! = nil
    var canLoadMore: Bool = true
    var discoverItems: [DiscoverItem]! = nil
    var page: Int = kDiscoverFirstPage
    var requestState: RequestState = RequestState.Ready
    
    var searchLocationParameter: SearchLocationParameter! = .NearMe
    var searchParamChoosenLocation: CLLocationCoordinate2D! = nil

    var userProfileId: Int = 0
    var supportUserProfile: Bool = false
    var stackSupport: Bool = false
    var profileViewController: ProfileViewController! = nil
    var profileContainerView = ProfileContainerView()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitle()
        self.setupProfileViewControllerIfNeeded()
        self.loadItemsFromDB()
        self.loadRemoteData()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.ins_removePullToRefresh()
            self.tableView.ins_endInfinityScroll()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupNavigationBarButtonItems()
        self.setupTableView()
    }
    
    func setupTitle() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    func setupProfileViewControllerIfNeeded() {
        if self.supportUserProfile {
            self.profileViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.profileController) as! ProfileViewController
            self.profileViewController.profileId = self.userProfileId
            self.profileViewController.updateContentClosure = { [weak self] () in
                self?.tableView.reloadData()
            }
            self.configureChildViewController(self.profileViewController, onView: self.profileContainerView)
            self.profileContainerView.configure(self.profileViewController)
        }
    }
    
    func setupNavigationBar() {
        if self.supportUserProfile {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, kShadowYOffset)
            self.navigationController?.navigationBar.layer.shadowOpacity = 0
            self.title = NSLocalizedString("Controller.Profile.Title", comment: String())
        } else {
            
            // add shadow
            self.navigationController?.navigationBar.layer.shadowOpacity = kDiscoverNavigationBarShadowOpacity;
            self.navigationController?.navigationBar.layer.shadowOffset = CGSizeZero;
            self.navigationController?.navigationBar.layer.shadowRadius = kDiscoverNavigationBarShadowRadius;
            self.navigationController?.navigationBar.layer.masksToBounds = false;
        }
    }
    
    func setupNavigationBarButtonItems() {
        if self.supportUserProfile == false {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoSearch)!, target: self, action: #selector(DiscoverViewController.searchButtonTapped))
        }
    }
    
    func setupTableView() {
        self.setupPullToRefresh()
        self.setupInfinityScroll()
        self.tableView.contentInset = UIEdgeInsetsZero
        if self.supportUserProfile {
            self.tableView.backgroundColor = UIColor.darkGreyBlue()
        }
    }
    
    func setupPullToRefresh() {
        self.tableView.ins_addPullToRefreshWithHeight(NavigationBar.defaultHeight) { [weak self] (scrollView) in
            self?.page = kDiscoverFirstPage
            self?.loadRemoteData()
        }
        
        let pullToRefresh = INSDefaultPullToRefresh(frame: Frame.pullToRefreshFrame, backImage: nil, frontImage: nil)
        self.tableView.ins_pullToRefreshBackgroundView.preserveContentInset = false
        self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh
        self.tableView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh)
    }
    
    func setupInfinityScroll() {
        self.tableView.ins_setInfinityScrollEnabled(true)
        self.tableView.ins_addInfinityScrollWithHeight(NavigationBar.defaultHeight) { [weak self] (scrollView) in
            if self?.requestState == RequestState.Ready {
                self?.page += 1
                self?.loadRemoteData()
            }
        }
        
        let indicator = INSDefaultInfiniteIndicator(frame: Frame.pullToRefreshFrame)
        self.tableView.ins_infiniteScrollBackgroundView.preserveContentInset = false
        self.tableView.ins_infiniteScrollBackgroundView.addSubview(indicator)
        indicator.startAnimating()
    }
    
    // MARK: - navigation bar
    override func backButtonHidden() -> Bool {
        return !self.supportUserProfile
    }
    
    override func backTapped() {
        if self.stackSupport == false {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        super.backTapped()
    }
    
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        
        self.storyActiveModel.removeData()
        let itemsCount = self.itemsCountToShow()
        let sortRaram = self.sortedString()
        let allItems = realm.objects(DiscoverItem).sorted(sortRaram)
        if allItems.count >=  itemsCount {
            self.discoverItems = Array(allItems[0..<itemsCount])
        } else {
            self.discoverItems = Array(allItems)
        }
        
        self.storyActiveModel.addItems(self.discoverItems, cellIdentifier: String(), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)

        self.storyDataSource.profileView = self.profileContainerView
        
        self.storyDataSource.reloadTable()
    }
    
    func sortedString() -> String {
        if self.searchLocationParameter == SearchLocationParameter.NearMe {
            return DiscoverItemSortParameter.nearMe.rawValue
        } else if self.searchLocationParameter == SearchLocationParameter.AllOverTheWorld {
            return DiscoverItemSortParameter.allOverTheWorld.rawValue
        } else if self.searchLocationParameter == SearchLocationParameter.ChoosenPlace {
            return DiscoverItemSortParameter.choosenPlace.rawValue
        }
        return String()
    }
    
    func itemsCountToShow() -> Int{
        return self.page * kDiscoverItemsInPage
    }
    
    // MARK: - remote
    func loadRemoteData() {
        if self.searchLocationParameter == SearchLocationParameter.NearMe {
            self.loadRemoteDataNearMe()
        } else if self.searchLocationParameter == SearchLocationParameter.AllOverTheWorld {
            self.loadRemoteDataAllOverTheWorld()
        } else if self.searchLocationParameter == SearchLocationParameter.ChoosenPlace {
            self.loadRemoteDataChoosenPlace()
        }
    }
    
    // MARK: - all over the world searching
    func loadRemoteDataAllOverTheWorld() {
        let params: [String: AnyObject] = ["page": self.page]
        self.retrieveDiscoverList(params)
    }
    
    func loadRemoteDataChoosenPlace() {
        self.retrieveDiscoverListWithLocation(self.searchParamChoosenLocation.latitude, longitude: self.searchParamChoosenLocation.longitude)
    }
    
    // MARK: - near me searching
    func loadRemoteDataNearMe() {
        // get current location
        if SessionHelper.sharedHelper.locationEnabled() {
            INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
                if location != nil {
                    self?.retrieveDiscoverListWithLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    self?.retrieveDiscoverListWithLocation(DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
                }
            }
        } else {
            self.retrieveDiscoverListWithLocation(DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
        }
    }
    
    func retrieveDiscoverListWithLocation(latitude: Double, longitude: Double) {
        let params: [String: AnyObject] = ["page": self.page,
                                           "radius": kDiscoverSearchingRadius,
                                           "location[latitude]": latitude,
                                           "location[longitude]": longitude
        ]
        self.retrieveDiscoverList(params)
    }
    
    func retrieveDiscoverList(params: [String: AnyObject]) {
        self.requestState = RequestState.Loading
        ApiClient.sharedClient.retrieveDiscoverList(self.page, params: params, success: { [weak self] (response) in
            
            DiscoverItemManager.saveDiscoverListItems(response as! [String: AnyObject], pageNumber: self!.page, itemsCountInPage: kDiscoverItemsInPage, searchLocationParameter: (self?.searchLocationParameter)!)
            
            self?.tableView.ins_endInfinityScroll()
            self?.tableView.ins_endPullToRefresh()
            
            let list: NSArray = response["discovered"] as! NSArray
            self?.tableView.ins_setInfinityScrollEnabled(list.count == kDiscoverItemsInPage)
            self?.requestState = RequestState.Ready
            
            self?.loadItemsFromDB()
            
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.tableView.ins_endInfinityScroll()
                self?.tableView.ins_endPullToRefresh()
                self?.requestState = RequestState.Ready
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - actions
    func showEditContentMenu(storyPointId: Int) {
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint.user.profile.id == SessionManager.currentUser().profile.id {
            self.showEditContentActionSheet(storyPointId)
        } else {
            self.showDefaultContentActionSheet(storyPointId)
        }       
    }
    
    func showEditContentActionSheet(storyPointId: Int) {
        let editPost = NSLocalizedString("Button.EditPost", comment: String())
        let deletePost = NSLocalizedString("Button.DeletePost", comment: String())
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [editPost, deletePost, directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: nil, buttons: buttons, handle: { [weak self] (buttonIndex) in
            if buttonIndex == EditContentOption.EditPost.rawValue {
                self?.routesOpenStoryPointEditController(storyPointId, storyPointUpdateHandler: { [weak self] in
                    self?.storyDataSource.reloadTable()
                })
            } else if buttonIndex == EditContentOption.DeletePost.rawValue {
                self?.deleteStoryPoint(storyPointId)
            }
            }
        )
    }
    
    func showDefaultContentActionSheet(storyPointId: Int) {
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let reportAbuse = NSLocalizedString("Button.ReportAbuse", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: reportAbuse, buttons: buttons, handle: { (buttonIndex) in
                //TODO: -
            }
        )
    }

    func deleteStoryPoint(storyPointId: Int) {
        let alertMessage = NSLocalizedString("Alert.DeleteStoryPoint", comment: String())
        let yesButton = NSLocalizedString("Button.Yes", comment: String())
        let noButton = NSLocalizedString("Button.No", comment: String())
        self.showAlert(nil, message: alertMessage, cancel: yesButton, buttons: [noButton]) { (buttonIndex) in
            if buttonIndex != 0 {
                self.showProgressHUD()
                ApiClient.sharedClient.deleteStoryPoint(storyPointId,
                                                        success: { [weak self] (response) in
                                                            let discoverItem = DiscoverItemManager.findWithStoryPoint(storyPointId)
                                                            let storyPoint = StoryPointManager.find(storyPointId)
                                                            if (storyPoint != nil) && (discoverItem != nil) {
                                                                DiscoverItemManager.delete(discoverItem)
                                                                StoryPointManager.delete(storyPoint)
                                                            }
                                                            self?.hideProgressHUD()
                                                            self?.loadItemsFromDB()
                                                        },
                                                        failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                            self?.hideProgressHUD()
                                                            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                                                        }
                )
            }
        }
    }
    
    func searchButtonTapped() {
        self.routerShowDiscoverChangeLocationPopupController(self)
    }
    
    // MARK: - DiscoverStoryPointCellDelegate
    func reloadTable(storyPointId: Int) {
        let storyPointIndex = self.discoverItems.indexOf({$0.id == storyPointId})
        let indexPath = NSIndexPath(forRow: storyPointIndex!, inSection: 0)
        let cellDataModel = self.storyActiveModel.cellData(indexPath)
        self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
        self.storyDataSource.reloadTable()
    }
    
    func editContentDidTap(storyPointId: Int) {
        self.showEditContentMenu(storyPointId)
    }
    
    func profileImageTapped(userId: Int) {
        self.routesOpenDiscoverControlelr(userId, supportUserProfile: true, stackSupport: true)
    }

    // MARK: - DiscoverStoryCellDelegate
    func didSelectStory(storyId: Int) {
        let itemIndex = self.discoverItems.indexOf({$0.id == storyId})
        let indexPath = NSIndexPath(forRow: itemIndex!, inSection: 0)
        let cellDataModel = self.storyActiveModel.cellData(indexPath)
        self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
        self.storyDataSource.reloadTable()
    }
    
    func didSelectStoryPoint(storyPoints: [StoryPoint], selectedIndex: Int, storyTitle: String) {
        if self.stackSupport {
            self.routesOpenStoryDetailViewController(storyPoints, selectedIndex: selectedIndex, storyTitle: storyTitle, stackSupport: true)
        } else {
            self.parentViewController?.routesOpenStoryDetailViewController(storyPoints, selectedIndex: selectedIndex, storyTitle: storyTitle, stackSupport: false)
        }
    }
    
    func didSelectMap() {
        // TODO:
    }
    
    func storyProfileImageTapped(userId: Int) {
        self.discoverShowProfileClosure(userId: userId)
    }

    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
    
    // MARK: - DiscoverChangeLocationDelegate
    func didSelectAllOverTheWorldLocation() {
        self.title = NSLocalizedString("Controller.DiscoverTitle.AllTheWorld", comment: String())
        self.updateData(SearchLocationParameter.AllOverTheWorld)
    }
    
    func didSelectNearMePosition() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
        self.updateData(SearchLocationParameter.NearMe)
    }
    
    func didSelectChoosenPlace(coordinates: CLLocationCoordinate2D, placeName: String) {
        self.title = placeName
        self.searchParamChoosenLocation = coordinates
        self.updateData(SearchLocationParameter.ChoosenPlace)
    }
    
    func updateData(searchLocationParameter: SearchLocationParameter) {
        self.tableView.setContentOffset(CGPointZero, animated: false)
        self.searchLocationParameter = searchLocationParameter
        self.page = kDiscoverFirstPage
        self.loadItemsFromDB()
        self.loadRemoteData()
    }
}
