//
//  NavigationBarItems.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension UIViewController {
    func addRightBarItem(title: String) -> () {
        let rightButton = RoundedButton(frame: Frame.doneButtonFrame)
        rightButton.setTitle(title, forState: .Normal)
        rightButton.addTarget(self, action: "rightBarButtonItemDidTap", forControlEvents: .TouchUpInside)
        let rightBarItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    // MARK: - method to override
    func rightBarButtonItemDidTap() {
        
    }
}
