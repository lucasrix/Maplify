//
//  StoryPointEditInfoViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import Haneke
import CoreLocation
import Haneke
import TPKeyboardAvoiding.TPKeyboardAvoidingScrollView

let kLocationInputFieldRightMargin: CGFloat = 30
let kEditInfoTopViewHeight: CGFloat = 281
let kStoryCellHeight: CGFloat = 44

class StoryPointEditInfoViewController: ViewController, SelectedStoryCellProtocol, ErrorHandlingProtocol {
    @IBOutlet weak var placeOrLocationLabel: UILabel!
    @IBOutlet weak var placeOrLocationTextField: UITextField!
    @IBOutlet weak var isPartOfStoryLabel: UILabel!
    @IBOutlet weak var addToStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardAvoidingScrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var storyPointKind: StoryPointKind! = nil
    var storyPointAttachmentId: Int = 0
    var storyPointDescription = ""
    var placesClient: GMSPlacesClient! = nil
    var location: MCMapCoordinate! = nil
    var selectedStories = [Story]()
    var selectedStoriesActiveModel: CSActiveModel! = nil
    var selectedStoriesDataSoure: CSBaseTableDataSource! = nil
    var storyPointId: Int = 0
    var updateContentClosure: (() -> ())! = nil
    var keyboardAvoidingModeEnabled: Bool = true
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.retrieveCurrentPlace()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupKeyboardAvoidingScrollView()
    }
    
    func setupKeyboardAvoidingScrollView() {
        if self.keyboardAvoidingModeEnabled == false {
            self.keyboardAvoidingScrollView.disableKeyboardAvoiding()
        }
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.StoryPointEditDescription.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
        
        self.placeOrLocationTextField.placeholder = NSLocalizedString("Text.Placeholder.EveryPostMustBeGeotagged", comment: String())
        
        let view = UIView(frame: CGRectMake(0, 0, kLocationInputFieldRightMargin, self.placeOrLocationTextField.frame.size.height))
        self.placeOrLocationTextField.rightViewMode = .Always
        self.placeOrLocationTextField.rightView = view
        
        self.setupStoryAttachmentLabels()
    }
    
    func setupStoryAttachmentLabels() {
        let attachmentLabel = (self.selectedStories.count > 0) ? NSLocalizedString("Label.PartOfStory", comment: String()) : NSLocalizedString("Label.IsThisPartOfStory", comment: String())
        let buttonTitle = (self.selectedStories.count > 0) ? NSLocalizedString("Button.ChangeStory", comment: String()) : NSLocalizedString("Button.AddToStory", comment: String())
        self.isPartOfStoryLabel.text = attachmentLabel
        self.addToStoryButton.setTitle(buttonTitle, forState: .Normal)
    }
    
    func configure(storyPointId: Int) {
        self.keyboardAvoidingScrollView.scrollEnabled = false
        
        let storyPoint = StoryPointManager.find(storyPointId)
        if storyPoint != nil {
            self.placeOrLocationTextField.text = storyPoint.location.address
        }
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - location
    func retrieveCurrentPlace() {
        if self.location != nil {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: self.location.latitude, longitude: self.location.longitude), completionHandler: { [weak self] (response, error) in
                if error != nil {
                    let title = NSLocalizedString("Alert.Error", comment: String())
                    let cancel = NSLocalizedString("Button.Ok", comment: String())
                    self?.showMessageAlert(title, message: (error?.description)!, cancel: cancel)
                } else {
                    let address = response?.firstResult()
                    self?.placeOrLocationTextField.text = address?.thoroughfare
                }
            })
        }
    }
    
    func showSelectedStories(selectedStories: [Story]) {
        self.selectedStoriesActiveModel = CSActiveModel()
        self.selectedStoriesActiveModel.addItems(selectedStories, cellIdentifier: String(SelectedStoryCell), sectionTitle: nil, delegate: self)
        self.selectedStoriesDataSoure = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.selectedStoriesActiveModel, delegate: self)
        self.tableViewHeightConstraint.constant = CGFloat(self.selectedStories.count) * kStoryCellHeight
        self.selectedStoriesDataSoure.reloadTable()
    }
    
    // MARK: - actions
    @IBAction func addToStoryTapped(sender: UIButton) {
        let selectedIds = self.selectedStories.map({$0.id})
        self.routesOpenAddToStoryController(selectedIds, storypointCreationSupport: false, pickedLocation: nil, locationString: String()) { [weak self] (selectedStories) in
            self?.configureSelectedStories(selectedStories)
        }
    }
    
    func configureSelectedStories(selectedStories: [Story]) {
        self.selectedStories = selectedStories
        self.setupStoryAttachmentLabels()
        self.showSelectedStories(self.selectedStories)
    }
    
    func hideKeyboard() {
        self.placeOrLocationTextField.endEditing(true)
    }
    
    func contentHeight() -> CGFloat {
        return kEditInfoTopViewHeight + CGFloat(self.selectedStories.count) * kStoryCellHeight
    }
    
    // MARK: - SelectedStoryCellProtocol
    func willDeleteStory(storyId: Int) {
        let storyIndex = self.selectedStories.indexOf({$0.id == storyId})
        self.selectedStories.removeAtIndex(storyIndex!)
        self.showSelectedStories(self.selectedStories)
        self.setupStoryAttachmentLabels()
        if self.updateContentClosure != nil {
            self.updateContentClosure()
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
