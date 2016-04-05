//
//  DiscoverViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

let discoverStoryPointCell = "DiscoverStoryPointCell"

class DiscoverViewController: ViewController, CSBaseTableDataSourceDelegate, DiscoverStoryPointCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: DiscoverTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var storyPoints: [StoryPoint]! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupTableView()
    }
    
    func setupTableView() {
        self.tableView.registerNib(UINib(nibName: discoverStoryPointCell, bundle: nil), forCellReuseIdentifier: discoverStoryPointCell)
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.Capture.Title", comment: String())
    }
    
    // MARK: - navigation bar
    override func backButtonHidden() -> Bool {
        return true
    }
    
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkBlueGrey()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        self.storyPoints = Array(realm.objects(StoryPoint))
        self.storyActiveModel.addItems(storyPoints, cellIdentifier: discoverStoryPointCell, sectionTitle: nil, delegate: self)
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    // MARK: - DiscoverStoryPointCellDelegate
    func reloadTable(storyPointId: Int) {
        let storyPointIndex = self.storyPoints.indexOf({$0.id == storyPointId})
        let indexPath = NSIndexPath(forRow: storyPointIndex!, inSection: 0)
        let cellDataModel = self.storyActiveModel.cellData(indexPath)
        self.storyActiveModel.selectModel(indexPath, selected: !cellDataModel.selected)
        self.storyDataSource.reloadTable()
    }
}

