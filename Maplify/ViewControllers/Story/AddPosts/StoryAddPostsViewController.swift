//
//  StoryAddPostsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

let kAddPostsAttributedMessageDefaultFontSize: CGFloat = 17
let kPlaceholderImageTopConstantScreen3_5: CGFloat = 20
let kPlaceholderImageTopConstantScreenGreater3_5: CGFloat = 56
let kCreateButtonTopConstantScreen3_5: CGFloat = 20
let kCreateButtonTopConstantScreenGreater3_5: CGFloat = 37

typealias createStoryClosure = ((storyId: Int) -> ())

class StoryAddPostsViewController: ViewController, StoryAddPostsDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myPostsLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var createFirstPostButton: UIButton!
    @IBOutlet weak var placeholderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createButtonTopConstraint: NSLayoutConstraint!
    
    var selectedStoryPoints: [StoryPoint]! = nil
    var delegate: AddPostsDelegate! = nil
    var storyDataSource: CSBaseTableDataSource! = nil
    var storyActiveModel = CSActiveModel()
    var isStoryModeCreation = false
    var storyName = String()
    var storyDescription = String()
    var createStoryCompletion: createStoryClosure! = nil
    
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
        self.setupViews()
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.AddPosts", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    func setupViews() {
        self.myPostsLabel.text = NSLocalizedString("Label.MyPosts", comment: String())
        
        let placeholderTextHighlited = NSLocalizedString("Text.Placeholder.AddPostsHighlited", comment: String())
        let placeholderTextDefault = NSLocalizedString("Text.Placeholder.AddPostsDefault", comment: String())
        let resultString = placeholderTextHighlited + " " + placeholderTextDefault
        let attributedString = NSMutableAttributedString(string: resultString)
        let highlitedRange = (resultString as NSString).rangeOfString(placeholderTextHighlited)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGreyBlue(), range: NSMakeRange(0, NSString(string: attributedString.string).length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(kAddPostsAttributedMessageDefaultFontSize), range: highlitedRange)
        self.placeholderLabel.attributedText = attributedString
        
        self.createFirstPostButton.setTitle(NSLocalizedString("Button.CreateFirstPost", comment: String()), forState: .Normal)
        self.createFirstPostButton.layer.cornerRadius = CornerRadius.defaultRadius
        
        self.placeholderTopConstraint.constant = UIScreen.mainScreen().isIPhoneScreenSize3_5() ? kPlaceholderImageTopConstantScreen3_5 : kPlaceholderImageTopConstantScreenGreater3_5
        self.createButtonTopConstraint.constant = UIScreen.mainScreen().isIPhoneScreenSize3_5() ? kCreateButtonTopConstantScreen3_5 : kCreateButtonTopConstantScreenGreater3_5
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
        let foundedStoryPoints = Array(realm.objects(StoryPoint).filter("user.id == \(SessionManager.currentUser().id)").sorted("created_at", ascending: false))
        self.topView.hidden = foundedStoryPoints.count == 0
        self.tableView.hidden = foundedStoryPoints.count == 0
        self.placeholderView.hidden = foundedStoryPoints.count > 0
        
        self.storyActiveModel.addItems(foundedStoryPoints, cellIdentifier: String(StoryAddPostsTableViewCell), sectionTitle: nil, delegate: self, boundingSize: UIScreen.mainScreen().bounds.size)
        
        if self.isStoryModeCreation == false {
            self.updateSelectedStoryPoints(foundedStoryPoints)
        }
        
        self.storyDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.storyActiveModel, delegate: self)
        self.storyDataSource.reloadTable()
    }
    
    func updateSelectedStoryPoints(foundedStoryPoints: [StoryPoint]) {
        let foundedStoryPointIds = foundedStoryPoints.map({$0.id})
        let storyPointsInStoryIds = self.selectedStoryPoints.map({$0.id})
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
        let selectedCellData = self.storyActiveModel.selectedModels()
        let selectedStoryPoints = selectedCellData.map({$0.model as! StoryPoint})
        
        if self.isStoryModeCreation == true {
            self.createStory(selectedStoryPoints)
        } else {
            self.updateStory(selectedStoryPoints)
            self.backTapped()
        }
    }
    
    // MARK: - actions
    @IBAction func createFirstPostTapped(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - private
    func updateStory(selectedStoryPoints: [StoryPoint]) {
        self.delegate?.didSelectStoryPoints(selectedStoryPoints)
    }
    
    func createStory(selectedStoryPoints: [StoryPoint]) {
        self.showProgressHUD()
        let storyPointIds = selectedStoryPoints.map({$0.id})
        var params: [String: AnyObject] = ["name": self.storyName, "discoverable": false, "story_point_ids": storyPointIds]
        if self.storyDescription != String() {
            params["description"] = self.storyDescription
        }
        
        ApiClient.sharedClient.createStory(params, success: { [weak self] (response) in
            self?.hideProgressHUD()
            let story = response as! Story
            StoryManager.saveStory(story)
            self?.createStoryCompletion?(storyId: story.id)
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
    
    // MARK: - StoryAddPostsDelegate
    func reloadData() {
        self.storyDataSource.reloadTable()
    }
}

protocol AddPostsDelegate {
    func didSelectStoryPoints(storyPoints: [StoryPoint])
}
