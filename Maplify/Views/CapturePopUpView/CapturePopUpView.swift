//
//  CapturePopUpView.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class CapturePopUpView: UIView {
    var view: UIView! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        self.view = NSBundle.mainBundle().loadNibNamed(String(CapturePopUpView), owner: self, options: nil).first as? UIView
        if (self.view != nil) {
            self.view.frame = bounds
            self.addSubview(self.view)
        }
    }
}
