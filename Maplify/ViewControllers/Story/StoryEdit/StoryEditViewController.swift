//
//  StoryEditViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import RealmSwift

class StoryEditViewController: ViewController, UITextViewDelegate, StoryEditDataSourceDelegate, AddPostsDelegate {
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionCharsNumberLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var pointsInStoryLabel: UILabel!
    @IBOutlet weak var addPostsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var storyDataSource: StoryEditTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    
    var storyId: Int = 0
    var storyUpdateHandler: (() -> ())! = nil
    var storyPoints = [StoryPoint]()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.setupData()
        self.populateViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDataFromDB()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupViews()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.EditStory", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
    }
    
    func setupViews() {
        self.setupStoryNameViews()
        self.setupStoryDescriptionViews()
        self.setupStoryPointsView()
    }
    
    func setupData() {
        let story = StoryManager.find(self.storyId)
        self.storyPoints = Array(story.storyPoints.sorted("created_at", ascending: false))
    }
    
    func setupStoryNameViews() {
        self.storyNameLabel.text = NSLocalizedString("Label.StoryName", comment: String())
        self.storyNameTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterBriefTitle", comment: String())
    }
    
    func setupStoryDescriptionViews() {
        self.descriptionLabel.text = NSLocalizedString("Label.Description", comment: String())
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.layer.cornerRadius = CornerRadius.defaultRadius
        self.descriptionTextView.clipsToBounds = true
        self.descriptionTextView.layer.borderWidth = Border.defaultBorderWidth
        self.descriptionTextView.layer.borderColor = UIColor.inactiveGrey().CGColor
    }
    
    func setupStoryPointsView() {
        self.pointsInStoryLabel.text = NSLocalizedString("Label.PostsInThisStory", comment: String())
        self.addPostsButton.setTitle(NSLocalizedString("Button.AddPosts", comment: String()).uppercaseString, forState: .Normal)
    }
    
    func populateViews() {
        let story = StoryManager.find(self.storyId)
        self.storyNameTextField.text = story.title
        self.descriptionTextView.text = story.storyDescription
        self.updateCharactersCountLabel(self.descriptionTextView.text.length)
    }
    
    func loadDataFromDB() {
        self.storyActiveModel.removeData()
        self.storyActiveModel.addItems(self.storyPoints, cellIdentifier: String(StoryEditPointCell), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
        self.storyDataSource = StoryEditTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.storyEditDelegate = self
        self.storyDataSource.reloadTable()
    }

    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - navigation bar actions
    override func rightBarButtonItemDidTap() {
        if self.storyNameTextField.text != String() {
            self.updateStory()
        }
    }
    
    // MARK: - actions
    @IBAction func addPostsTapped(sender: UIButton) {
        self.routesOpenStoryAddPostsViewController(self.storyId, delegate: self, storyModeCreation: false, storyName: String(), storyDescription: String(), storyCreateClosure: nil)
    }
    
    func updateStory() {
        self.showProgressHUD()
        let params: [String: AnyObject] = ["name": self.storyNameTextField.text!, "description": self.descriptionTextView.text, "discoverable": true, "story_point_ids": self.storyPoints.map({$0.id})]
        ApiClient.sharedClient.updateStory(self.storyId, params: params, success: { [weak self] (response) in
            StoryManager.saveStory(response as! Story)
            self?.setupData()
            self?.loadDataFromDB()
            self?.hideProgressHUD()
            self?.backTapped()
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
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let resultCharactersCount = (self.descriptionTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text).length
        if resultCharactersCount <= kDescriptionTextViewMaxCharactersCount {
            self.updateCharactersCountLabel(resultCharactersCount)
            return true
        }
        return false
    }
    
    func updateCharactersCountLabel(charactersCount: Int) {
        let substringOf = NSLocalizedString("Substring.Of", comment: String())
        let substringChars = NSLocalizedString("Substring.Chars", comment: String())
        self.descriptionCharsNumberLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
    }
    
    // MARK: - StoryEditDataSourceDelegate
    func didRemoveItem(indexPath: NSIndexPath) {
        let cellData = self.storyActiveModel.cellData(indexPath)
        let storyPointToDelete = cellData.model as! StoryPoint
        let index = self.storyPoints.indexOf({$0.id == storyPointToDelete.id})
        self.storyPoints.removeAtIndex(index!)
        self.storyDataSource.removeRow(indexPath)
    }
    
    // MARK: - AddPostsDelegate
    func didSelectStoryPoints(storyPoints: [StoryPoint]) {
        self.storyPoints = storyPoints
        self.loadDataFromDB()
    }
}
