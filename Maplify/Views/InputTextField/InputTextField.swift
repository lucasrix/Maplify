//
//  InputTextField.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

private let kDefaultOpacity: CGFloat = 0.55
private let kSeparatorViewAnimationDuration: NSTimeInterval = 0.3
private let kInputTextFieldAlphaMin: CGFloat = 0.0
private let kInputTextFieldAlphaMax: CGFloat = 1.0

class InputTextField : UIView, UITextFieldDelegate {
    var view: UIView! = nil
    var delegate: InputTextFieldDelegate! = nil
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconHighlitedImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.view = NSBundle.mainBundle().loadNibNamed(String(InputTextField), owner: self, options: nil).first as? UIView
        if (self.view != nil) {
            self.view.frame = bounds
            self.addSubview(self.view)
            self.textField.delegate = self
        }
    }
    
    func setupTextField(placeholder: String, defaultIconName: String, highlitedIconName: String) {
        self.textField.textColor = UIColor.whiteColor()
        self.textField.attributedPlaceholder = NSAttributedString(string:placeholder,
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(kDefaultOpacity)])
        self.iconImageView.image = UIImage(named: defaultIconName)
        self.iconHighlitedImageView.image = UIImage(named: highlitedIconName)
        
        self.setDefaultState()
    }
    
    func setDefaultState() {
        self.updateViewWithAnimation(false, errorShow: false, separatrorColor: UIColor.warmGrey())
    }
    
    func setHiglitedState() {
        self.updateViewWithAnimation(true, errorShow: false, separatrorColor: UIColor.dodgerBlue())
    }
    
    func setErrorState(errorMessage: String) {
        self.updateViewWithAnimation(false, errorShow: true, separatrorColor: UIColor.lightishRed())
        self.errorLabel.text = errorMessage
    }
    
    private func updateViewWithAnimation(highlitedImageShow: Bool, errorShow: Bool, separatrorColor: UIColor) {
        UIView.animateWithDuration(kSeparatorViewAnimationDuration) { () -> Void in
            self.separatorView.backgroundColor = separatrorColor
            
            let iconAlpha: CGFloat = highlitedImageShow == true ? kInputTextFieldAlphaMax : kInputTextFieldAlphaMin
            let iconAlphaAnother: CGFloat = highlitedImageShow == false ? kInputTextFieldAlphaMax : kInputTextFieldAlphaMin
            self.iconImageView.alpha = iconAlphaAnother
            self.iconHighlitedImageView.alpha = iconAlpha
            
            let errorAlpha: CGFloat = errorShow == true ? kInputTextFieldAlphaMax : kInputTextFieldAlphaMin
            self.errorLabel.alpha = errorAlpha
        }
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func editingDidBegin(sender: UITextField) {
        self.setHiglitedState()
        self.delegate?.editingBegin?(self)
    }
    
    @IBAction func editingDidEnd(sender: UITextField) {
        self.delegate?.editingEnd?(self)
    }
    
    @IBAction func editingChanged(sender: UITextField) {
        self.setHiglitedState()
        self.delegate?.editingChanged?(self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.delegate?.didPressReturnKey?(self)
        return true
    }
}

@objc protocol InputTextFieldDelegate {
    optional func editingBegin(inputTextField: InputTextField)
    optional func editingEnd(inputTextField: InputTextField)
    optional func editingChanged(inputTextField: InputTextField)
    optional func didPressReturnKey(inputTextField: InputTextField)
}