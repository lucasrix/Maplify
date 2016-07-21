//
//  EditStoryViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

typealias editStoryClosure = ((storyId: Int, cancelled: Bool) -> ())

class EditStoryViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: EditStoryDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var headerView: EditStoryHeaderView! = nil
    
    var storyId: Int = 0
    var editStoryCompletion: editStoryClosure! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadData()
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
        self.headerView.setup()
    }
    
    func setupDataSource() {
        self.storyDataSource = EditStoryDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.headerView = self.headerView
    }
    
    func loadData() {
        self.storyActiveModel.removeData()
        let story = StoryManager.find(self.storyId)
        let storyPoints = Converter.listToArray(story.storyPoints, type: StoryPoint.self)
        self.storyActiveModel.addItems(storyPoints, cellIdentifier: String(EditStoryTableViewCell), sectionTitle: nil, delegate: self)
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
        print("right tapped")
    }
}
