//
//  InputTextField.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

private let kDefaultOpacity: CGFloat = 0.55

class InputTextField : UIView {
    var view: UIView! = nil
    var defaultIconName: String! = nil
    var highlitedIconName: String! = nil
    var delegate: InputTextFieldDelegate! = nil
    
    @IBOutlet weak var iconImageView: UIImageView!
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
        }
    }
    
    func setupTextField(placeholder: String, defaultIconName: String, highlitedIconName: String) {
        self.textField.textColor = UIColor.whiteColor()
        self.textField.attributedPlaceholder = NSAttributedString(string:placeholder,
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(kDefaultOpacity)])
        self.defaultIconName = defaultIconName
        self.highlitedIconName = highlitedIconName
        
        self.setDefaultState()
    }
    
    func setDefaultState() {
        self.iconImageView.image = UIImage(named: self.defaultIconName)
        self.separatorView.backgroundColor = UIColor.warmGrey()
        self.errorLabel.hidden = true
    }
    
    func setHiglitedState() {
        self.iconImageView.image = UIImage(named: self.highlitedIconName)
        self.separatorView.backgroundColor = UIColor.dodgerBlue()
        self.errorLabel.hidden = true
    }
    
    func setErrorState(errorMessage: String) {
        self.iconImageView.image = UIImage(named: self.defaultIconName)
        self.separatorView.backgroundColor = UIColor.lightishRed()
        self.errorLabel.hidden = false
        self.errorLabel.text = errorMessage
    }
    
    // MARK: UITextFieldDelegate
    
    @IBAction func editingDidBegin(sender: UITextField) {
        self.setHiglitedState()
        self.delegate?.editingBegin?(self)
    }
    
    @IBAction func editingDidEnd(sender: UITextField) {
        self.setDefaultState()
        self.delegate?.editingEnd?(self)
    }
}

@objc protocol InputTextFieldDelegate {
    optional func editingBegin(inputTextField: InputTextField)
    optional func editingEnd(inputTextField: InputTextField)
    optional func didPressReturnKey(inputTextField: InputTextField)
}