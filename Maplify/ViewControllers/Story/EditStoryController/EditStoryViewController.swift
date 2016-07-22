//
//  EditStoryViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import CoreLocation
import UIKit

typealias editStoryClosure = ((storyId: Int, cancelled: Bool) -> ())

class EditStoryViewController: ViewController, EditStoryTableViewCellDelegate, StoryUpdateManagerDelegate, EditStoryHeaderViewDelegate, AddPostsDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: EditStoryDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var headerView: EditStoryHeaderView! = nil
    
    var storyId: Int = 0
    var story: Story! = nil
    var storyPoints = [StoryPoint]()
    var storyPointDrafts = [StoryPointDraft]()
    var editStoryCompletion: editStoryClosure! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.prepareData()
        self.populateHeaderView()
        self.updateData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBarItems()
    }
    
    // MARK: - setup
    func setup() {
        self.populateTitle()
        self.setupHeaderView()
        self.setupDataSource()
    }
    
    func populateTitle() {
        self.title = NSLocalizedString("Controller.EditStory", comment: String())
    }
    
    func setupNavigationBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(EditStoryViewController.cancelButtonTapped))
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
    }
    
    func setupHeaderView() {
        self.headerView = NSBundle.mainBundle().loadNibNamed(String(EditStoryHeaderView), owner: nil, options: nil).last as! EditStoryHeaderView
        self.headerView.setup(delegate: self)
    }
    
    func updateData() {
        self.loadData()
        self.populateTableView()
    }
    
    func populateHeaderView() {
        if self.story != nil {
            self.headerView?.populateHeader(self.story)
        }
    }
    
    func prepareData() {
        self.story = StoryManager.find(self.storyId)
        self.storyPoints = Converter.listToArray(story.storyPoints, type: StoryPoint.self)
    }
    
    func loadData() {
        self.storyPointDrafts.removeAll()
        for storyPoint in self.storyPoints {
            let storyPointDraft = StoryPointDraft()
            storyPointDraft.id = storyPoint.id
            storyPointDraft.coordinate = CLLocationCoordinate2D(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
            storyPointDraft.address = storyPoint.location.address
            storyPointDraft.storyPointDescription = storyPoint.text
            storyPointDraft.storyPointKind = storyPoint.kind
            if let attachment = storyPoint.attachment {
                storyPointDraft.attachmentUrl = attachment.file_url
            }
            let storyLinks = Converter.listToArray(storyPoint.storiesLinks, type: StoryLink.self)
            storyPointDraft.storiesIds = storyLinks.map({$0.id})
            if storyPointDraft.storiesIds.contains(self.storyId) == false {
                storyPointDraft.storiesIds.append(self.storyId)
            }
            self.storyPointDrafts.append(storyPointDraft)
        }
    }
    
    func setupDataSource() {
        self.storyDataSource = EditStoryDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.headerView = self.headerView
    }
    
    func populateTableView() {
        self.storyActiveModel.removeData()
        self.storyActiveModel.addItems(self.storyPointDrafts, cellIdentifier: String(EditStoryTableViewCell), sectionTitle: nil, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    func cancelButtonTapped() {
        let alertMessage = NSLocalizedString("Alert.StoryEditExit", comment: String())
        let yesButton = NSLocalizedString("Button.YesExit", comment: String())
        let noButton = NSLocalizedString("Button.No", comment: String())
        self.showAlert(nil, message: alertMessage, cancel: noButton, buttons: [yesButton]) { [weak self] (buttonIndex) in
            if buttonIndex == AlertButtonIndexes.Submit.rawValue {
                self?.editStoryCompletion?(storyId: 0, cancelled: true)
            }
        }
    }
    
    override func rightBarButtonItemDidTap() {
        self.updateStory()
    }
    
    private func updateStory() {
        self.showProgressHUD()
        let storyUpdateManager = StoryUpdateManager.sharedManager
        storyUpdateManager.delegate = self
        storyUpdateManager.updateStory(self.storyId, storyName: (self.headerView?.titleTextField?.text)!, storyDescription: (self.headerView?.descriptionTextView?.text)!, storyPointDrafts: self.storyPointDrafts)
    }
    
    // MARK: - EditStoryTableViewCellDelegate
    func getIndexOfObject(draft: StoryPointDraft, completion: ((index: Int, count: Int) -> ())!) {
        let index = self.storyActiveModel.indexPathOfModel(draft)
        completion?(index: index.row, count: self.storyActiveModel.numberOfItems(0))
    }
    
    func changeLocationDidTap(completion: ((location: CLLocationCoordinate2D, address: String) -> ())!) {
        self.routesOpenStoryCreateAddLocationController { [weak self] (place) in
            completion(location: place.coordinate, address: place.name)
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    // MARK: - StoryUpdateManagerDelegate
    func updatingStoryDidSuccess(storyId: Int) {
        // TODO:
    }
    
    func updatingStoryDidFail(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        self.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
    }
    
    func updatingStoryPointDidStartCreating(draft: StoryPointDraft) {
        // TODO:
    }
    
    func updatingStoryPointDidSuccess(draft: StoryPointDraft) {
        // TODO:
    }
    
    func updatingStoryPointDidFail(draft: StoryPointDraft) {
        // TODO:
    }
    
    func allOperationsCompleted(storyId: Int) {
        self.hideProgressHUD()
        self.editStoryCompletion?(storyId: storyId, cancelled: false)
    }
    
    // MARK: - EditStoryHeaderViewDelegate
    func addToStoryDidTap() {
        self.routesOpenStoryAddPostsViewController(self.storyPoints, delegate: self, storyModeCreation: false, storyName: String(), storyDescription: String(), createStoryCompletion: nil)
    }
    
    // MARK: - AddPostsDelegate
    func didSelectStoryPoints(storyPoints: [StoryPoint]) {
        self.storyPoints = storyPoints
        self.updateData()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
