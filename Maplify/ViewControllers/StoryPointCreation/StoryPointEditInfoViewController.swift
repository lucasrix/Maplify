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

class StoryPointEditInfoViewController: ViewController, SelectedStoryCellProtocol, ErrorHandlingProtocol {
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var placeOrLocationLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var placeOrLocationTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var isPartOfStoryLabel: UILabel!
    @IBOutlet weak var addToStoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardAvoidingScrollView: TPKeyboardAvoidingScrollView!
    
    var storyPointKind: StoryPointKind! = nil
    var storyPointAttachmentId = ""
    var storyPointDescription = ""
    var placesClient: GMSPlacesClient! = nil
    var location: MCMapCoordinate! = nil
    var selectedStories = [Story]()
    var selectedStoriesActiveModel: CSActiveModel! = nil
    var selectedStoriesDataSoure: CSBaseTableDataSource! = nil
    var storyPointId: Int = 0
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.retrieveCurrentPlace()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.StoryPointEditDescription.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
        
        self.captionLabel.text = NSLocalizedString("Label.Caption", comment: String())
        self.placeOrLocationLabel.text = NSLocalizedString("Label.PlaceOrLocation", comment: String())
        self.tagsLabel.text = NSLocalizedString("Label.Tags", comment: String())
        
        self.captionTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterBriefCaption", comment: String())
        self.placeOrLocationTextField.placeholder = NSLocalizedString("Text.Placeholder.EveryPostMustBeGeotagged", comment: String())
        
        let view = UIView(frame: CGRectMake(0, 0, kLocationInputFieldRightMargin, self.placeOrLocationTextField.frame.size.height))
        self.placeOrLocationTextField.rightViewMode = .Always
        self.placeOrLocationTextField.rightView = view
        self.tagsTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterTag", comment: String())
        
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
            self.captionTextField.text = storyPoint.caption
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
        self.selectedStoriesDataSoure.reloadTable()
    }
    
    // MARK: - actions
    @IBAction func addToStoryTapped(sender: UIButton) {
        self.routesOpenAddToStoryController { [weak self] (selectedStories) in
            self?.selectedStories = selectedStories
            self?.setupStoryAttachmentLabels()
            self?.showSelectedStories((self?.selectedStories)!)
        }
    }
    
    // MARK: - navigation bar item actions
    override func rightBarButtonItemDidTap() {
        self.hideKeyboard()
        
        if self.placeOrLocationTextField.text?.length > 0 {
            self.showProgressHUD()
            if self.storyPointKind == StoryPointKind.Text {
                self.remotePostStoryPoint(0)
            } else {
                self.remotePostAttachment()
            }
        } else {
            self.showMessageAlert(nil, message: NSLocalizedString("Alert.AddPlaceOrLocation", comment: String()), cancel: NSLocalizedString("Button.Ok", comment: String()))
        }
    }
    
    // MARK: - private
    func remotePostAttachment() {
        var file: NSData! = nil
        var params: [String: AnyObject]! = nil
        if self.storyPointKind == StoryPointKind.Photo {
            let cache = Shared.imageCache
            cache.fetch(key: self.storyPointAttachmentId).onSuccess { data in
                file = UIImagePNGRepresentation(data)
                params = ["mimeType": "image/png", "fileName": "photo.png"]
            }
        } else if self.storyPointKind == StoryPointKind.Audio {
            file = NSFileManager.defaultManager().contentsAtPath(self.storyPointAttachmentId)
            params = ["mimeType": "audio/m4a", "fileName": "audio.m4a"]
        } else if self.storyPointKind == StoryPointKind.Video {
            let url = NSURL(string: self.storyPointAttachmentId)
            file = NSData(contentsOfURL: url!)
            params = ["mimeType": "video/quicktime", "fileName": "video.mov"]
        }
       
        ApiClient.sharedClient.postAttachment(file, params: params, success: { [weak self] (response) -> () in
            self?.remotePostStoryPoint((response as! Attachment).id)
            }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func remotePostStoryPoint(attachmentId: Int) {
        let locationDict: [String: AnyObject] = ["latitude":self.location.latitude, "longitude":self.location.longitude]
        let kind = self.storyPointKind.rawValue
        var storyPointDict: [String: AnyObject] = ["caption":self.captionTextField.text!,
                                            "kind":kind,
                                            "text":self.storyPointDescription,
                                        "location":locationDict]
        if self.storyPointKind != StoryPointKind.Text {
            storyPointDict["attachment_id"] = attachmentId
        }
        
        if self.selectedStories.count > 0 {
            storyPointDict["story_ids"] = self.selectedStories.map({$0.id})
        }
        
        ApiClient.sharedClient.createStoryPoint(storyPointDict, success: { [weak self] (response) -> () in
            let realm = try! Realm()
            try! realm.write {
                realm.add(response as! StoryPoint, update: true)
            }
            self?.hideProgressHUD()
            self?.navigationController?.popToRootViewControllerAnimated(true)
            }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
                self?.hideProgressHUD()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func hideKeyboard() {
        self.captionTextField.endEditing(true)
        self.placeOrLocationTextField.endEditing(true)
        self.tagsTextField.endEditing(true)
    }
    
    // MARK: - SelectedStoryCellProtocol
    func willDeleteStory(storyId: Int) {
        let storyIndex = self.selectedStories.indexOf({$0.id == storyId})
        self.selectedStories.removeAtIndex(storyIndex!)
        self.showSelectedStories(self.selectedStories)
        self.setupStoryAttachmentLabels()
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
