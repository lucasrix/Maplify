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

let discoverStoryPointCell = "DiscoverStoryPointCell"
let kDiscoverNavigationBarShadowOpacity: Float = 0.8
let kDiscoverNavigationBarShadowRadius: CGFloat = 3

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
        return UIColor.darkBlueGrey()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        self.storyPoints = Array(realm.objects(StoryPoint))
        self.storyActiveModel.addItems(storyPoints, cellIdentifier: discoverStoryPointCell, sectionTitle: nil, delegate: self)
        self.storyDataSource = DiscoverTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    // MARK: - actions
    func showEditContentMenu(storyPointId: Int) {
        let editPost = NSLocalizedString("Button.EditPost", comment: String())
        let deletePost = NSLocalizedString("Button.DeletePost", comment: String())
        let directions = NSLocalizedString("Button.Directions", comment: String())
        let sharePost = NSLocalizedString("Button.SharePost", comment: String())
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttons = [editPost, deletePost, directions, sharePost]
        
        self.showActionSheet(nil, message: nil, cancel: cancel, destructive: nil, buttons: buttons, handle: { [weak self] (buttonIndex) in
                if buttonIndex == EditContentOption.EditPost.rawValue {
                    //TODO: -
                } else if buttonIndex == EditContentOption.DeletePost.rawValue {
                    //TODO: -
                }
            }
        )

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
}

