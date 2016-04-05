//
//  DiscoverViewController.swift
//  Maplify
//
//  Created by Sergey on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

let discoverStoryPointCell = "DiscoverStoryPointCell"

class DiscoverViewController: ViewController, CSBaseTableDataSourceDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: DiscoverTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
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
        let storyPoints = Array(realm.objects(StoryPoint))
        self.storyActiveModel.addItems(storyPoints, cellIdentifier: discoverStoryPointCell, sectionTitle: nil, delegate: self)
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
}

