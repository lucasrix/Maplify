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
let kDiscoverBarMinLimitOpacity: CGFloat = 0.2

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

class DiscoverViewController: ViewController, CSBaseTableDataSourceDelegate, DiscoverStoryPointCellDelegate, DiscoverTableDataSourceDelegate, DiscoverStoryCellDelegate, ErrorHandlingProtocol, DiscoverChangeLocationDelegate, ProfileViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: DiscoverTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var discoverShowProfileClosure: ((userId: Int) -> ())! = nil
    var canLoadMore: Bool = true
    var discoverItems = [DiscoverItem]()
    var page: Int = kDiscoverFirstPage
    var requestState: RequestState = RequestState.Ready
    
    var searchLocationParameter: SearchLocationParameter! = .NearMe
    var searchParamChoosenLocation: CLLocationCoordinate2D! = nil

    var userProfileId: Int = 0
    var supportUserProfile: Bool = false
    var stackSupport: Bool = false
    
    var profileView: ProfileView! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitle()
        self.setupProfileViewIfNeeded()
        self.configureProfileViewIfNeeded()
        self.setupDataSource()
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
        self.loadItemsFromDB()
        self.loadRemoteData()
        self.setupNavigationBarColorWithContentOffsetIfNeeded(self.tableView.contentOffset)
    }
    
    func setupDataSource() {
        self.storyActiveModel = CSActiveModel()
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.scrollDelegate = self
        self.storyDataSource.profileView = self.profileView
    }
    
    func setupTitle() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    func setupProfileViewIfNeeded() {
        if self.supportUserProfile {
            self.profileView = NSBundle.mainBundle().loadNibNamed("ProfileView", owner: nil, options: nil).last as! ProfileView
            self.profileView.updateContentClosure = { [weak self] () in
                self?.tableView.reloadData()
            }
            
            self.profileView.didChangeImageClosure = { [weak self] () in
                self?.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
            }
            self.profileView.delegate = self
        }
    }
    
    func configureProfileViewIfNeeded() {
        if self.supportUserProfile {
            self.profileView.setupWithUser(self.userProfileId, parentViewController: self)
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
        self.setupPullToRefreshIfNeeded()
        self.setupInfinityScrollIfNeeded()

        self.tableView.contentInset = UIEdgeInsetsZero
        if self.supportUserProfile {
            self.tableView.backgroundColor = UIColor.darkerGreyBlue()
        }
    }
    
    func setupPullToRefreshIfNeeded() {
        if self.supportUserProfile == false {
            self.tableView.ins_addPullToRefreshWithHeight(NavigationBar.defaultHeight) { [weak self] (scrollView) in
                self?.page = kDiscoverFirstPage
                self?.loadRemoteData()
            }
            
            let pullToRefresh = INSDefaultPullToRefresh(frame: Frame.pullToRefreshFrame, backImage: nil, frontImage: nil)
            self.tableView.ins_pullToRefreshBackgroundView.preserveContentInset = false
            self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh
            self.tableView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh)
        }
    }
    
    func setupInfinityScrollIfNeeded() {
        if self.supportUserProfile == false {
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
        return self.supportUserProfile
    }
    
    override func navigationBarColor() -> UIColor {
        return self.supportUserProfile ? UIColor.clearColor() : UIColor.darkGreyBlue()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        
        self.storyActiveModel.removeData()
        if self.supportUserProfile {
            self.storyActiveModel.removeData()
            let currentUserId = self.userProfileId
            let allItems = realm.objects(DiscoverItem).filter("storyPoint.user.id == \(currentUserId) OR story.user.id == \(currentUserId)").sorted("created_at", ascending: false)
            self.discoverItems = Array(allItems)
        } else {
            let itemsCount = self.itemsCountToShow()
            let sortRaram = self.sortedString()
            let allItems = realm.objects(DiscoverItem).filter("\(sortRaram) != 0").sorted(sortRaram)
            if allItems.count >=  itemsCount {
                self.discoverItems = Array(allItems[0..<itemsCount])
            } else {
                self.discoverItems = Array(allItems)
            }
        }
        
        self.storyActiveModel.addItems(self.discoverItems, cellIdentifier: String(), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
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
    
    func itemsCountToShow() -> Int {
        return self.page * kDiscoverItemsInPage
    }
    
    // MARK: - remote
    func loadRemoteData() {
        if self.supportUserProfile {
            self.loadUserDiscoverData()
        } else {
            self.loadDiscoverRemoteData()
        }
    }
    
    func loadUserDiscoverData() {
        ApiClient.sharedClient.getUserStoryPoints(self.userProfileId,
            success: { [weak self] (response) in
                let storyPoints = response as! [StoryPoint]
                ApiClient.sharedClient.getUserStories((self?.userProfileId)!, success: { [weak self] (response) in
                    let stories = response as! [Story]
                    UserRequestResponseHelper.sortAndMerge(storyPoints, stories: stories)
                    self?.loadItemsFromDB()
                    },
                failure: { (statusCode, errors, localDescription, messages) in
                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                })
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
    }
    
    func loadDiscoverRemoteData() {
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
    override func rightBarButtonItemDidTap() {
        let photo = (self.profileView.userImageView.image != nil) ? UIImagePNGRepresentation(self.profileView.userImageView.image!) : nil
        self.showProgressHUD()
        
        ApiClient.sharedClient.updateProfile(SessionManager.currentUser().profile, photo: photo,
            success: { [weak self] (response) in
                self?.hideProgressHUD()
                self?.navigationItem.rightBarButtonItem = nil
                
                let profile = response as! Profile
                ProfileManager.saveProfile(profile)
                SessionManager.updateProfileForCurrrentUser(profile)
            },
            failure:  { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        })

    }
    
    func showEditContentMenu(storyPointId: Int) {
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint.user.profile.id == SessionManager.currentUser().profile.id {
            
            self.showStoryPointEditContentActionSheet( { [weak self] (selectedIndex) -> () in
                
                if selectedIndex == StoryPointEditContentOption.EditPost.rawValue {
                    self?.routesOpenStoryPointEditController(storyPointId, storyPointUpdateHandler: { [weak self] in
                        self?.storyDataSource.reloadTable()
                        })
                } else if selectedIndex == StoryPointEditContentOption.DeletePost.rawValue {
                    self?.deleteStoryPoint(storyPointId)
                } else if selectedIndex == StoryPointEditContentOption.SharePost.rawValue {
                    self?.shareStoryPoint(storyPointId)
                }
            })
        } else {
            self.showStoryPointDefaultContentActionSheet( { [weak self] (selectedIndex) in
                
                if selectedIndex == StoryPointDefaultContentOption.SharePost.rawValue {
                    self?.shareStoryPoint(storyPointId)
                }
            })
        }       
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
    
    func shareStoryPoint(storyPointId: Int) {
        self.routesOpenShareStoryPointViewController(storyPointId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    // MARK: - story
    func showEditStoryContentMenu(storyId: Int) {
        let story = StoryManager.find(storyId)
        if story.user.profile.id == SessionManager.currentUser().profile.id {
            self.showEditStoryContentActionSheet({ [weak self] (selectedIndex) in
                if selectedIndex == StoryEditContentOption.EditStory.rawValue {
                    self?.routesOpenStoryEditController(storyId, storyUpdateHandler: { [weak self] in
                        self?.storyDataSource.reloadTable()
                        })
                } else if selectedIndex == StoryEditContentOption.DeleteStory.rawValue {
                    self?.deleteStory(storyId)
                } else if selectedIndex == StoryEditContentOption.ShareStory.rawValue {
                    self?.shareStory(storyId)
                }
            })
        } else {
            self.showStoryDefaultContentActionSheet( { [weak self] (selectedIndex) in
                if selectedIndex == StoryDefaultContentOption.ShareStory.rawValue {
                    self?.shareStory(storyId)
                }
            })
        }
    }
    
    func deleteStory(storyId: Int) {
        // TODO: delete
    }
    
    func shareStory(storyId: Int) {
        self.routesOpenShareStoryViewController(storyId) { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
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
        if self.supportUserProfile == false {
            self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
        }
    }

    // MARK: - DiscoverStoryCellDelegate
    func didSelectStory(storyId: Int) {
        let itemIndex = self.discoverItems.indexOf({$0.id == storyId})
        if itemIndex != NSNotFound {
            let indexPath = NSIndexPath(forRow: itemIndex!, inSection: 0)
            let cellDataModel = self.storyActiveModel.cellData(indexPath)
            self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
            self.storyDataSource.reloadTable()
        }
    }
    
    func didSelectStoryPoint(storyPoints: [StoryPoint], selectedIndex: Int, storyTitle: String) {
        self.routesOpenStoryDetailViewController(storyPoints, selectedIndex: selectedIndex, storyTitle: storyTitle, stackSupport: true)
    }
    
    func didSelectMap() {
        // TODO:
    }
    
    func storyProfileImageTapped(userId: Int) {
        self.discoverShowProfileClosure(userId: userId)
    }
    
    func editStoryContentDidTap(storyId: Int) {
        self.showEditStoryContentMenu(storyId)
    }

    // MARK: - ProfileViewDelegate
    func followButtonDidTap() {
        //TODO:
    }
    
    func createStoryButtonDidTap() {
        self.routesOpenStoryCreateController { [weak self] () in
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    func editButtonDidTap() {
        self.routesOpenEditProfileController(self.userProfileId, photo: self.profileView.userImageView.image) { [weak self] () in
            self?.configureProfileViewIfNeeded()
        }
    }
    
    // MARK: - DiscoverTableDataSourceDelegate
    func discoverTableDidScroll(scrollView: UIScrollView) {
        self.setupNavigationBarColorWithContentOffsetIfNeeded(scrollView.contentOffset)
    }
    
    func setupNavigationBarColorWithContentOffsetIfNeeded(contentOffset: CGPoint) {
        if self.supportUserProfile {
            let profileViewHeight = self.profileView.contentHeight()
            let alphaMin = NavigationBar.navigationBarAlphaMin
            let alphaMax = NavigationBar.defaultOpacity
            if (contentOffset.y > profileViewHeight * alphaMin && contentOffset.y <= profileViewHeight * alphaMax) {
                var alpha: CGFloat = contentOffset.y / profileViewHeight
                if alpha < kDiscoverBarMinLimitOpacity {
                    alpha = 0
                }
                self.setNavigationBarTransparentWithAlpha(alpha)
            } else if (contentOffset.y > profileViewHeight) {
                self.setNavigationBarTransparentWithAlpha(alphaMax)
            }
        }
    }
    
    func setNavigationBarTransparentWithAlpha(alpha: CGFloat) {
        let color = UIColor.darkBlueGrey().colorWithAlphaComponent(alpha)
        let image = UIImage(color: color)!
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
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
