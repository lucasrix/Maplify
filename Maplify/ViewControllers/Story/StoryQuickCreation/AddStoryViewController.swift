 //
//  AddStoryViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import RealmSwift
import INSPullToRefresh.UIScrollView_INSPullToRefresh

typealias updateStoryClosure = ([Story]) -> ()

class AddStoryViewController: ViewController, CSBaseTableDataSourceDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var myStoriesLabel: UILabel!
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderDescriptionLabel: UILabel!
    @IBOutlet weak var placeholderCreateButton: UIButton!
    
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var updatedStoryIds: updateStoryClosure! = nil
    var selectedIndexPathes: [NSIndexPath]! = nil
    var selectedIds: [Int]! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadRemoteData()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.ins_removePullToRefresh()
            self.tableView.ins_endInfinityScroll()
        }
    }
    
    // MARK: - setup
    func setup() {
        self.setupTableView()
        self.setupViews()
        self.setupPlaceholderView()
    }
    
    func setupTableView() {
        self.setupPullToRefresh()
        self.setupInfinityScroll()
    }
    
    func setupPullToRefresh() {
        self.tableView.ins_addPullToRefreshWithHeight(NavigationBar.defaultHeight) { [weak self] (scrollView) in
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
            self?.loadRemoteData()
        }
        
        let indicator = INSDefaultInfiniteIndicator(frame: Frame.pullToRefreshFrame)
        self.tableView.ins_infiniteScrollBackgroundView.preserveContentInset = false
        self.tableView.ins_infiniteScrollBackgroundView.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.AddToStory.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Add", comment: String()))
        self.myStoriesLabel.text = NSLocalizedString("Label.MyStories", comment: String()).uppercaseString
        self.createStoryButton.setTitle(NSLocalizedString("Button.CreateStory", comment: String()).uppercaseString, forState: .Normal)
    }
    
    func setupPlaceholderView() {
        self.placeholderDescriptionLabel.text = NSLocalizedString("Label.CreateStoryPlaceholder", comment: String())
        let buttonTitle = NSLocalizedString("Button.CreateStoryPlaceholder", comment: String())
        self.placeholderCreateButton.setTitle(buttonTitle, forState: .Normal)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.getCurrentUserStories(self.storyActiveModel.page,
            success: { [weak self] (response) in
                self?.tableView.ins_endPullToRefresh()
                self?.tableView.ins_endInfinityScroll()
                StoryManager.saveStories(response as! [Story])
                self?.storyActiveModel.updatePage()
                self?.loadItemsFromDB()
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.tableView.ins_endPullToRefresh()
                self?.tableView.ins_endInfinityScroll()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    func updateStoryPointDetails(stories: [Story]) {
        self.tableView.hidden = !Bool(stories.count)
        self.placeholderView.hidden = Bool(stories.count)
        
        self.selectedIndexPathes = self.storyActiveModel.selectedIndexPathes()
        self.storyActiveModel.removeData()
        
        let cellIdentifier = "StoryQuickCreationCell"
        self.storyActiveModel.addItems(stories, cellIdentifier: cellIdentifier, sectionTitle: nil, delegate: self)
        self.storyActiveModel.selectModels(self.selectedIndexPathes)
        self.storyDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.allowMultipleSelection = true
        self.selectStories(stories)
        
        self.storyDataSource.reloadTable()
    }
    
    func selectStories(stories: [Story]) {
        for storyId in self.selectedIds {
            let index = stories.indexOf({$0.id == storyId})
            if index != NSNotFound {
                let indexPath = NSIndexPath(forRow: index!, inSection: 0)
                self.storyActiveModel.selectModel(indexPath, selected: true)
            }
        }
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        let userId = SessionManager.currentUser().id
        let stories = Array(realm.objects(Story).filter("user.id == \(userId)").sorted("created_at", ascending: false))
        self.updateStoryPointDetails(stories)
    }
    
    func createStoryPoint(name: String) {
        self.showProgressHUD()
        ApiClient.sharedClient.createStory(name, discoverable: false,
                success: { [weak self] (response) in
                    StoryManager.saveStories([response as! Story])
                    self?.hideProgressHUD()
                    self?.loadItemsFromDB()
            },
                failure: { [weak self] (statusCode, errors, localDescription, messages) in
                    self?.hideProgressHUD()
                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    func createStory() {
        let title = NSLocalizedString("Alert.Title.CreateStory", comment: String())
        let message = NSLocalizedString("Alert.CreateStory.Description", comment: String())
        let okButton = NSLocalizedString("Button.Ok", comment: String())
        let cancelButton = NSLocalizedString("Button.Cancel", comment: String())
        self.showInputMessageAlert(title, message: message, ok: okButton, cancel: cancelButton) { [weak self] (alertAction, alertController) in
            if alertAction.style == .Default {
                let inputField = alertController.textFields?.first
                self?.createStoryPoint((inputField?.text)!)
            }
        }
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        if self.storyActiveModel.selectedIndexPathes().count > 0 {
            let selectedStories = self.storyActiveModel.selectedModels().map({$0.model as! Story})
            self.updatedStoryIds(selectedStories)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func createStoryPlaceholderButtonDidTap(sender: AnyObject) {
        self.createStory()
    }
    
    @IBAction func createStoryButtonDidTap(sender: AnyObject) {
        self.createStory()
    }
    
    // MARK: - CSBaseTableDataSourceDelegate
    func didSelectModel(model: AnyObject, selection: Bool, indexPath: NSIndexPath) {
        self.storyActiveModel.selectModel(indexPath, selected: selection)
        self.storyDataSource.reloadTable()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
