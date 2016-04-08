//
//  DiscoverViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

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

let discoverStoryPointCell = "DiscoverStoryPointCell"
let discoverStoryCell = "DiscoverStoryCell"
let kDiscoverNavigationBarShadowOpacity: Float = 0.8
let kDiscoverNavigationBarShadowRadius: CGFloat = 3

class DiscoverViewController: ViewController, CSBaseTableDataSourceDelegate, DiscoverStoryPointCellDelegate, DiscoverStoryCellDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: DiscoverTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var storyPoints: [StoryPoint]! = nil
    var stories: [Story]! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
        
        // add shadow
        self.navigationController!.navigationBar.backgroundColor = UIColor.blackColor();
        self.navigationController!.navigationBar.layer.shadowOpacity = kDiscoverNavigationBarShadowOpacity;
        self.navigationController!.navigationBar.layer.shadowOffset = CGSizeZero;
        self.navigationController!.navigationBar.layer.shadowRadius = kDiscoverNavigationBarShadowRadius;
        self.navigationController!.navigationBar.layer.masksToBounds = false;
    }
    
    // MARK: - navigation bar
    override func backButtonHidden() -> Bool {
        return true
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
        self.storyPoints = Array(realm.objects(StoryPoint))
        self.storyActiveModel.addItems(storyPoints, cellIdentifier: discoverStoryPointCell, sectionTitle: nil, delegate: self)
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
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
                                                            let storyPoint = StoryPointManager.find(storyPointId)
                                                            if storyPoint != nil {
                                                                StoryPointManager.delete(storyPointId)
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
    
    // MARK: - DiscoverStoryPointCellDelegate
    func reloadTable(storyPointId: Int) {
        let storyPointIndex = self.storyPoints.indexOf({$0.id == storyPointId})
        let indexPath = NSIndexPath(forRow: storyPointIndex!, inSection: 0)
        let cellDataModel = self.storyActiveModel.cellData(indexPath)
        self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
        self.storyDataSource.reloadTable()
    }
    
    func editContentDidTap(storyPointId: Int) {
        self.showEditContentMenu(storyPointId)
    }

    // MARK: - DiscoverStoryCellDelegate
    func didSelectStory(storyId: Int) {
        let storyIndex = self.stories.indexOf({$0.id == storyId})
        let indexPath = NSIndexPath(forRow: storyIndex!, inSection: 0)
        let cellDataModel = self.storyActiveModel.cellData(indexPath)
        self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
        self.storyDataSource.reloadTable()
    }
    
    func didSelectStoryPoint(storyPointId: Int) {
        // TODO:
    }
    
    func didSelectMap() {
        // TODO:
    }

    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

