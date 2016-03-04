//
//  SignupViewController.swift
//  Maplify
//
//  Created by Sergey on 3/3/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import AFImageHelper

class SignupPhotoController: ViewController, InputTextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var firstNameField: InputTextField!
    @IBOutlet weak var lastNameField: InputTextField!
    @IBOutlet weak var setPhotoLabelView: UIView!
    @IBOutlet weak var setPhotoLabel: UILabel!
    @IBOutlet weak var setPhotoImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var account: Account! = nil
    var imagePicker: UIImagePickerController! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupTextFields()
        self.setupPhotoLabelView()
        self.setupImageView()
        self.setupNextButton()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
        self.descriptionLabel.text = NSLocalizedString("Controller.Signup.description", comment: String())
        self.setPhotoLabel.text = NSLocalizedString("Controller.Signup.setPhoto", comment: String())
    }
    
    func setupTextFields() {
        self.firstNameField.setupTextField(NSLocalizedString("Text.Placeholder.FirstName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.firstNameField.textField.textAlignment = NSTextAlignment.Center
        self.lastNameField.setupTextField(NSLocalizedString("Text.Placeholder.LastName", comment: String()), defaultIconName: nil, highlitedIconName: nil)
        self.lastNameField.textField.textAlignment = NSTextAlignment.Center
    }
    
    func setupPhotoLabelView() {
        self.setPhotoLabelView.layer.cornerRadius = CornerRadius.defaultRadius
        self.setPhotoLabelView.clipsToBounds = true
    }
    
    func setupImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "imageViewDidTap")
        self.setPhotoImage.addGestureRecognizer(tapGesture)
    }
    
    func setupNextButton() {
        let nextButton = DoneButton(frame: Frame.doneButtonFrame)
        nextButton.setTitle(NSLocalizedString("Button.Next", comment: String()), forState: .Normal)
        nextButton.addTarget(self, action: "nextButtonDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: nextButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    // MARK: - actions
    func imageViewDidTap() {
        self.firstNameField.textField.endEditing(true)
        self.lastNameField.textField.endEditing(true)
        if (self.imagePicker == nil) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
        }
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func nextButtonDidTap() {
        //TODO:
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage {
            self.setPhotoImage.contentMode = .ScaleAspectFit
            self.setPhotoImage.image = pickedImage.roundCornersToCircle()
        }
        self.setPhotoLabelView.hidden = true
        dismissViewControllerAnimated(true, completion: nil)
    }
}