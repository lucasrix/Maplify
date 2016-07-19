//
//  StoryCreateAddInfoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

class StoryCreateAddInfoViewController: ViewController, StoryAddMediaTableViewCellDelegate, StoryCreateManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: StoryAddMediaDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var headerView: StoryAddMediaHeaderView! = nil
    
    var createStoryCompletion: createStoryClosure! = nil
    var selectedDrafts = [StoryPointDraft]()

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBarItems()
        self.populateTitle()
    }
    
    // MARK: - setup
    func setup() {
        self.setupHeaderView()
        self.setupDataSource()
    }
    
    func populateTitle() {
        let localizedString = NSString.localizedStringWithFormat(NSLocalizedString("Count.Assets", comment: String()), self.selectedDrafts.count)
        self.title = String(localizedString)
    }
    
    func setupNavigationBarItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButton(UIImage(named: ButtonImages.icoCancel)!, target: self, action: #selector(StoryCreateAddInfoViewController.cancelButtonTapped))
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
    }
    
    func setupHeaderView() {
        self.headerView = NSBundle.mainBundle().loadNibNamed(String(StoryAddMediaHeaderView), owner: nil, options: nil).last as! StoryAddMediaHeaderView
        self.headerView.setup()
    }
    
    func setupDataSource() {
        self.storyDataSource = StoryAddMediaDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.headerView = self.headerView
    }
    
    func loadData() {
        self.storyActiveModel.removeData()
        self.storyActiveModel.addItems(self.selectedDrafts, cellIdentifier: String(StoryAddMediaTableViewCell), sectionTitle: nil, delegate: self)
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
        let alertMessage = NSLocalizedString("Alert.StoryCreateCancel", comment: String())
        let yesButton = NSLocalizedString("Button.YesDelete", comment: String())
        let noButton = NSLocalizedString("Button.No", comment: String())
        self.showAlert(nil, message: alertMessage, cancel: noButton, buttons: [yesButton]) { [weak self] (buttonIndex) in
            if buttonIndex == AlertButtonIndexes.Submit.rawValue {
                self?.createStoryCompletion?(storyId: 0, cancelled: true)
            }
        }
    }
    
    override func rightBarButtonItemDidTap() {
        if self.headerView?.titleTextField?.text?.characters.count > 0 {
            let storyName = self.headerView?.titleTextField?.text
            self.postStory(storyName!)
        } else {
            // TODO:
        }
    }
    
    func postStory(storyName: String) {
        self.showProgressHUD()
        let storyManager = StoryCreateManager.sharedManager
        storyManager.delegate = self
        let storyDescription = self.headerView?.descriptionTextView?.text
        storyManager.postStory(storyName, storyDescription: storyDescription, storyPointDrafts: self.selectedDrafts)
    }
    
    // MARK: - StoryAddMediaTableViewCellDelegate
    func getIndexOfObject(draft: StoryPointDraft, completion: ((index: Int, count: Int) -> ())!) {
        let index = self.storyActiveModel.indexPathOfModel(draft)
        completion?(index: index.row, count: self.storyActiveModel.numberOfItems(0))
    }
    
    func addLocationDidTap(completion: ((location: CLLocationCoordinate2D, address: String) -> ())!) {
        self.routesOpenStoryCreateAddLocationController { [weak self] (place) in
            completion(location: place.coordinate, address: place.name)
            self?.navigationController?.popToViewController(self!, animated: true)
        }
    }
    
    // MARK: - StoryCreateManagerDelegate
    func creationStoryDidSuccess(storyId: Int) {
        self.hideProgressHUD()
    }
    
    func creationStoryDidFail(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        self.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
    }
    
    func creationStoryPointDidStartCreating(draft: StoryPointDraft) {
        draft.downloadState = .InProgress
        self.updateCell(draft)
    }
    
    func creationStoryPointDidSuccess(draft: StoryPointDraft) {
        draft.downloadState = .Success
        self.updateCell(draft)
    }
    
    func creationStoryPointDidFail(draft: StoryPointDraft) {
        draft.downloadState = .Fail
        self.updateCell(draft)
    }
    
    func allOperationsCompleted(storyId: Int) {
        self.createStoryCompletion?(storyId: storyId, cancelled: false)
    }
    
    private func updateCell(draft: StoryPointDraft) {
        let index = self.selectedDrafts.indexOf(draft)
        if (index != nil) && (index != NSNotFound) {
            let indexPath = NSIndexPath(forRow: index!, inSection: 0)
            dispatch_async(dispatch_get_main_queue(), {
                self.storyDataSource.reloadCell([indexPath])
            })
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
