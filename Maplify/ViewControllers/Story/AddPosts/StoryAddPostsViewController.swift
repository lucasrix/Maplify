//
//  StoryAddPostsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

class StoryAddPostsViewController: ViewController, StoryAddPostsDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyId: Int = 0
    var delegate: AddPostsDelegate! = nil
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
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
        let foundedStoryPoints = Array(realm.objects(StoryPoint).filter("user.id == \(SessionManager.currentUser().id)"))
        
        self.storyActiveModel.addItems(foundedStoryPoints, cellIdentifier: String(StoryAddPostsTableViewCell), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
        
        self.updateSelectedStoryPoints(foundedStoryPoints)
        
        self.storyDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    func updateSelectedStoryPoints(foundedStoryPoints: [StoryPoint]) {
        let foundedStoryPointIds = foundedStoryPoints.map({$0.id})
        let story = StoryManager.find(self.storyId)
        let storyPointsInStory = Converter.listToArray(story.storyPoints, type: StoryPoint.self)
        let storyPointsInStoryIds = storyPointsInStory.map({$0.id})
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
        self.updateStory()
        self.backTapped()
    }
    
    // MARK: - private
    func updateStory() {
        let selectedCellData = self.storyActiveModel.selectedModels()
        let selectedStoryPoints = selectedCellData.map({$0.model as! StoryPoint})

        self.delegate?.didSelectStoryPoints(selectedStoryPoints)
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
