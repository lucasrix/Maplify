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

class StoryPointEditInfoViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var placeOrLocationLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var placeOrLocationTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var isPartOfStoryLabel: UILabel!
    @IBOutlet weak var addToStoryButton: UIButton!
    
    var storyPointKind: StoryPointKind! = nil
    var storyPointAttachmentId = ""
    var storyPointDescription = ""
    var placesClient: GMSPlacesClient! = nil
    var location: MCMapCoordinate! = nil
    
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
        self.tagsTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterTag", comment: String())
        
        self.isPartOfStoryLabel.text = NSLocalizedString("Label.IsThisPartOfStory", comment: String())
        self.addToStoryButton.setTitle(NSLocalizedString("Button.AddToStory", comment: String()), forState: .Normal)
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
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: self.location.latitude, longitude: self.location.longitude), completionHandler: { [weak self] (response, error) in
            if error != nil {
                print(error)
            } else {
                let address = response?.firstResult()
                self?.placeOrLocationTextField.text = address?.thoroughfare
            }
        })
    }
    
    // MARK: - actions
    @IBAction func addToStoryTapped(sender: UIButton) {
        // TODO:
    }
    
    // MARK: - navigation bar item actions
    override func rightBarButtonItemDidTap() {
        self.hideKeyboard()
        self.showProgressHUD()
        if self.storyPointKind == StoryPointKind.Text {
            self.remotePostStoryPoint(0)
        } else {
            self.remotePostAttachment()
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
        
        ApiClient.sharedClient.createStoryPoint(storyPointDict, success: { [weak self] (response) -> () in
            let realm = try! Realm()
            try! realm.write {
                realm.add(response as! StoryPoint)
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
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
