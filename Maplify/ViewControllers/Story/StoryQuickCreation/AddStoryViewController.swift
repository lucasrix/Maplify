//
//  AddStoryViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import RealmSwift

class AddStoryViewController: ViewController, CSBaseTableDataSourceDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var myStoriesLabel: UILabel!
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderDescriptionLabel: UILabel!
    @IBOutlet weak var placeholderCreateButton: UIButton!
    
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        self.tableView.hidden = !Bool(stories.count)
        self.placeholderView.hidden = Bool(stories.count)
        
        self.storyActiveModel.removeData()
        let cellIdentifier = "StoryQuickCreationCell"
        self.storyActiveModel.addItems(stories, cellIdentifier: cellIdentifier, sectionTitle: nil, delegate: self)
        self.storyDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.allowMultipleSelection = true
        self.storyDataSource.reloadTable()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        let stories = Array(realm.objects(Story))
        self.updateStoryPointDetails(stories)
    }
    
    func createStoryPoint(name: String) {
        self.showProgressHUD()
        ApiClient.sharedClient.createStory(name, discoverable: false,
                                           success: { [weak self] (response) in
                                            StoryManager.saveStory(response as! Story)
                                            self?.hideProgressHUD()
                                            self?.loadItemsFromDB()
            },
                                           failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                            self?.hideProgressHUD()
                                            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    func createStory() {
        let title = NSLocalizedString("Alert.Title.CreateStory", comment: String())
        let message = NSLocalizedString("Alert.CreateStory.Description", comment: String())
        let okButton = NSLocalizedString("Button.Ok", comment: String())
        let cancelButton = NSLocalizedString("Button.Cancel", comment: String())
        self.showInputMessageAlert(title, message: message, ok: okButton, cancel: cancelButton) { [weak self] (alertAction, alertController) in
            if alertAction.style == .Default {
                let inputField = alertController.textFields?.first
                self?.createStoryPoint((inputField?.text)!)
            }
        }
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        // TODO:
    }
    
    
    @IBAction func createStoryPlaceholderButtonDidTap(sender: AnyObject) {
        self.createStory()
    }
    
    @IBAction func createStoryButtonDidTap(sender: AnyObject) {
        self.createStory()
    }
    
    // MARK: - CSBaseTableDataSourceDelegate
    func didSelectModel(model: AnyObject, selection: Bool, indexPath: NSIndexPath) {
        self.storyActiveModel.selectModel(indexPath, selected: !selection)
        self.storyDataSource.reloadTable()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
    
}
