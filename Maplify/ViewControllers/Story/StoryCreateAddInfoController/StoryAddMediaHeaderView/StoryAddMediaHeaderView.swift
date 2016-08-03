//
//  StoryAddMediaHeaderView.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import KMPlaceholderTextView
import UIKit

let kTopMargin: CGFloat = 4
let kStoryTitleTextFieldHeight: CGFloat = 36
let kMidMargin: CGFloat = 4
let kStoryDescriptionTextViewHeight: CGFloat = 108
let kBottomMargin: CGFloat = 1
let kTitlePlaceholderTextAlpha: CGFloat = 0.6
let kHeaderViewTitleMaxLenght: Int = 25

class StoryAddMediaHeaderView: UIView, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var titleView: UIView!

    func viewHeight() -> CGFloat {
        let headerHeight = kTopMargin + kStoryTitleTextFieldHeight + kMidMargin + kStoryDescriptionTextViewHeight + kBottomMargin
        return headerHeight
    }
    
    func setup() {
        let titlePlaceholder = self.storyNamePlaceholderText()
        self.titleTextField.attributedPlaceholder = NSAttributedString(string:titlePlaceholder, attributes:[NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(kTitlePlaceholderTextAlpha)])
        self.titleTextField.delegate = self
        
        self.descriptionTextView.placeholder = NSLocalizedString("Text.Placeholder.StoryAddMediaDescription", comment: String())
    }
    
    func setStoryNameDefaultState() {
        self.titleView.backgroundColor = UIColor.whiteColor()
    }
    
    func setStoryNameErrorState() {
        self.titleView.backgroundColor = UIColor.redPink().colorWithAlphaComponent(kEmptyLocationViewAlpha)
        self.titleTextField.attributedPlaceholder = NSAttributedString(string:self.storyNamePlaceholderText(), attributes:[NSForegroundColorAttributeName: UIColor.redPink()])
    }
    
    func readyToCreate() -> Bool {
        return self.titleTextField?.text!.characters.count > 0
    }
    
    // MARK: - actions
    @IBAction func textFieldChangedText(sender: UITextField) {
        if sender.text?.characters.count == 0 {
            self.setStoryNameErrorState()
        } else {
            self.setStoryNameDefaultState()
        }
    }
    
    // MARK: - private
    func storyNamePlaceholderText() -> String {
        return NSLocalizedString("Text.Placeholder.StoryAddMediaTitle", comment: String())
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let resultText = (self.titleTextField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return resultText.characters.count <= kHeaderViewTitleMaxLenght
    }
}
