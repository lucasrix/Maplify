//
//  StoryPointCreationPopupViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/19/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointCreationPopupViewController: ViewController {
    
    var delegate: StoryPointCreationPopupDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false
    }
}

@objc protocol StoryPointCreationPopupDelegate {
    optional func ambientDidTapped()
    optional func photoVideoDidTapped()
    optional func textDidTapped()
}