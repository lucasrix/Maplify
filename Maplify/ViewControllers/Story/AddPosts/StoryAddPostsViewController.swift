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
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
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
    
    // MARK: - navigation bar actions
    override func rightBarButtonItemDidTap() {
        self.updateStory()
        self.backTapped()
    }
    
    // MARK: - private
    func updateStory() {
        let selectedCellData = self.storyActiveModel.selectedModels()
        let selectedStoryPoints = selectedCellData.map({$0.model as! StoryPoint})
        
        let story = StoryManager.find(self.storyId)
        let realm = try! Realm()
        try! realm.write {
            story.storyPoints.removeAll()
            for storyPoint in selectedStoryPoints {
                story.storyPoints.append(storyPoint)
            }
        }
        
    }
    
    // MARK: - StoryAddPostsDelegate
    func reloadData() {
        self.storyDataSource.reloadTable()
    }
}
