//
//  StoryAddPostsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

typealias createStoryClosure = ((storyId: Int) -> ())

class StoryAddPostsViewController: ViewController, StoryAddPostsDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myPostsLabel: UILabel!
    
    var selectedStoryPoints: [StoryPoint]! = nil
    var delegate: AddPostsDelegate! = nil
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var isStoryModeCreation = false
    var storyName = String()
    var storyDescription = String()
    var createStoryCompletion: createStoryClosure! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadRemoteData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDataFromDB()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.myPostsLabel.text = NSLocalizedString("Label.MyPosts", comment: String())
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.AddPosts", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadDataFromDB() {
        self.storyActiveModel.removeData()
        let realm = try! Realm()
        let foundedStoryPoints = Array(realm.objects(StoryPoint).filter("user.id == \(SessionManager.currentUser().id)").sorted("created_at", ascending: false))
        
        self.storyActiveModel.addItems(foundedStoryPoints, cellIdentifier: String(StoryAddPostsTableViewCell), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
        
        if self.isStoryModeCreation == false {
            self.updateSelectedStoryPoints(foundedStoryPoints)
        }
        
        self.storyDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    func updateSelectedStoryPoints(foundedStoryPoints: [StoryPoint]) {
        let foundedStoryPointIds = foundedStoryPoints.map({$0.id})
        let storyPointsInStoryIds = self.selectedStoryPoints.map({$0.id})
        for storyPoint in storyPointsInStoryIds {
            if let index = foundedStoryPointIds.indexOf(storyPoint) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.storyActiveModel.selectModel(indexPath, selected: true)
            }
        }
    }
    
    // MARK: - remote
    func loadRemoteData() {
        let userId = SessionManager.currentUser().id
        ApiClient.sharedClient.getUserStoryPoints(userId, success: { [weak self] (response) in
            StoryPointManager.saveStoryPoints(response as! [StoryPoint])
            self?.loadDataFromDB()
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - navigation bar actions
    override func rightBarButtonItemDidTap() {
        let selectedCellData = self.storyActiveModel.selectedModels()
        let selectedStoryPoints = selectedCellData.map({$0.model as! StoryPoint})
        
        if self.isStoryModeCreation == true {
            self.createStory(selectedStoryPoints)
        } else {
            self.updateStory(selectedStoryPoints)
            self.backTapped()
        }
    }
    
    // MARK: - private
    func updateStory(selectedStoryPoints: [StoryPoint]) {
        self.delegate?.didSelectStoryPoints(selectedStoryPoints)
    }
    
    func createStory(selectedStoryPoints: [StoryPoint]) {
        self.showProgressHUD()
        let storyPointIds = selectedStoryPoints.map({$0.id})
        var params: [String: AnyObject] = ["name": self.storyName, "discoverable": false, "story_point_ids": storyPointIds]
        if self.storyDescription != String() {
            params["description"] = self.storyDescription
        }
        
        ApiClient.sharedClient.createStory(params, success: { [weak self] (response) in
            self?.hideProgressHUD()
            let story = response as! Story
            StoryManager.saveStory(story)
            self?.createStoryCompletion?(storyId: story.id)
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
    
    // MARK: - StoryAddPostsDelegate
    func reloadData() {
        self.storyDataSource.reloadTable()
    }
}

protocol AddPostsDelegate {
    func didSelectStoryPoints(storyPoints: [StoryPoint])
}
