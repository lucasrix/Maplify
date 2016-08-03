//
//  EditStoryHeaderView.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import KMPlaceholderTextView
import UIKit

let kEditStoryBottomMargin: CGFloat = 38

protocol EditStoryHeaderViewDelegate {
    func addToStoryDidTap()
}

class EditStoryHeaderView: UIView, UITextFieldDelegate {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var addToStoryButton: UIButton!
    
    var delegate: EditStoryHeaderViewDelegate! = nil
    
    func viewHeight() -> CGFloat {
        let headerHeight = kTopMargin + kStoryTitleTextFieldHeight + kMidMargin + kStoryDescriptionTextViewHeight + kEditStoryBottomMargin
        return headerHeight
    }
    
    func setup(delegate delegate: EditStoryHeaderViewDelegate!) {
        self.delegate = delegate
        let titlePlaceholder = self.storyNamePlaceholderText()
        self.titleTextField.attributedPlaceholder = NSAttributedString(string:titlePlaceholder, attributes:[NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(kTitlePlaceholderTextAlpha)])
        self.titleTextField.delegate = self
        self.descriptionTextView.placeholder = NSLocalizedString("Text.Placeholder.StoryAddMediaDescription", comment: String())
        self.addToStoryButton.setTitle(NSLocalizedString("Button.PlusAddToStory", comment: String()).uppercaseString, forState: .Normal)
    }
    
    func populateHeader(story: Story) {
        self.titleTextField.text = story.title
        self.descriptionTextView.text = story.storyDescription
    }
    
    func setStoryNameDefaultState() {
        self.titleView.backgroundColor = UIColor.whiteColor()
    }
    
    func setStoryNameErrorState() {
        self.titleView.backgroundColor = UIColor.redPink().colorWithAlphaComponent(kEmptyLocationViewAlpha)
        self.titleTextField.attributedPlaceholder = NSAttributedString(string:self.storyNamePlaceholderText(), attributes:[NSForegroundColorAttributeName: UIColor.redPink()])
    }
    
    func readyToEdit() -> Bool {
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
    
    @IBAction func addToStoryTapped(sender: UIButton) {
        self.delegate?.addToStoryDidTap()
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
