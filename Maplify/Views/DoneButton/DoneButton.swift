//
//  DoneButton.swift
//  Maplify
//
//  Created by Sergey on 3/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDoneButtonFontSize: CGFloat = 14

class DoneButton: RoundedButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setup() {
        super.setup()
        
        let size = CGSizeMake(Frame.doneButtonFrame.width, Frame.doneButtonFrame.height)
        let defaultImage = UIImage(color: UIColor.dodgerBlue(), size: size)?.roundCorners(CornerRadius.defaultRadius)
        let selectedImage = UIImage(color: UIColor.waterBlue(), size: size)?.roundCorners(CornerRadius.defaultRadius)
        
        self.setBackgroundImage(defaultImage, forState: .Normal)
        self.setBackgroundImage(selectedImage, forState: .Highlighted)
        self.setBackgroundImage(selectedImage, forState: .Selected)
        
        self.titleLabel?.font = UIFont.fontHelveticaBold(kDoneButtonFontSize)
    }
}