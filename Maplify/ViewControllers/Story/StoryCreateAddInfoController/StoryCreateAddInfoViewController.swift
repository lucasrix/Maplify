//
//  StoryCreateAddInfoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import UIKit

class StoryCreateAddInfoViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: StoryAddMediaDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var headerView: StoryAddMediaHeaderView! = nil
    
    var createStoryCompletion: createStoryClosure! = nil
    var selectedAssets = [PHAsset]()

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
        let localizedString = NSString.localizedStringWithFormat(NSLocalizedString("Count.Assets", comment: String()), self.selectedAssets.count)
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
        self.storyActiveModel.addItems(self.selectedAssets, cellIdentifier: String(StoryAddMediaTableViewCell), sectionTitle: nil, delegate: self)
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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightBarButtonItemDidTap() {
        // TODO:
    }
}
