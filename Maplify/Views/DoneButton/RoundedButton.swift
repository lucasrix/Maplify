//
//  RoundedButton.swift
//  Maplify
//
//  Created by Sergey on 3/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDoneButtonFontSize: CGFloat = 14

class RoundedButton: UIButton {
    var defaultColor: UIColor! = nil
    var highlightedColor: UIColor! = nil
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                self.backgroundColor = self.highlightedColor
            }
            else {
                self.backgroundColor = self.defaultColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup(defaultColor: UIColor = UIColor.dodgerBlue(), selectedColor: UIColor = UIColor.waterBlue(), font: UIFont = UIFont.systemFontOfSize(kDoneButtonFontSize)) {
        self.layer.cornerRadius = CornerRadius.defaultRadius
        self.backgroundColor = defaultColor
        self.defaultColor = defaultColor
        self.highlightedColor = selectedColor
        self.titleLabel?.font = font
    }
}