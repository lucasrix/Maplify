//
//  AddStoryViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import RealmSwift

class AddStoryViewController: ViewController {
    @IBOutlet weak var myStoriesLabel: UILabel!
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.AddToStory.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Add", comment: String()))
        self.myStoriesLabel.text = NSLocalizedString("Label.MyStories", comment: String()).uppercaseString
        self.createStoryButton.setTitle(NSLocalizedString("Button.CreateStory", comment: String()).uppercaseString, forState: .Normal)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func updateStoryPointDetails(stories: [Story]) {
        self.storyActiveModel.removeData()
        let cellIdentifier = "StoryQuickCreationCell"
        self.storyActiveModel.addItems(stories, cellIdentifier: cellIdentifier, sectionTitle: nil, delegate: self)
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        let stories = Array(realm.objects(Story))
        self.updateStoryPointDetails(stories)
//        self.updateMapActiveModel(storyPoints)
//        self.setupMapDataSource()
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        // TODO:
    }
    
    @IBAction func createStoryButtonDidTap(sender: AnyObject) {
        let alertTitle = NSLocalizedString("Alert.Title.CreateStory", comment: String())
        let alertMessage = NSLocalizedString("Alert.CreateStory.Description", comment: String())
        
    }
    
}
