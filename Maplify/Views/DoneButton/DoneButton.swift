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
        self.backgroundColor = UIColor.dodgerBlue()
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont.fontHelveticaBold(kDoneButtonFontSize)
    }
}