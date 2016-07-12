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

class StoryAddMediaHeaderView: UIView {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!

    func viewHeight() -> CGFloat {
        let headerHeight = kTopMargin + kStoryTitleTextFieldHeight + kMidMargin + kStoryDescriptionTextViewHeight + kBottomMargin
        return headerHeight
    }
    
    func setup() {
        let titlePlaceholder = NSLocalizedString("Text.Placeholder.StoryAddMediaTitle", comment: String())
        self.titleTextField.attributedPlaceholder = NSAttributedString(string:titlePlaceholder, attributes:[NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(kTitlePlaceholderTextAlpha)])
        
        self.descriptionTextView.placeholder = NSLocalizedString("Text.Placeholder.StoryAddMediaDescription", comment: String())
    }

}
