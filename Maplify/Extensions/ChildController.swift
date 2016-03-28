//
//  ChildController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension ViewController {
    func configureChildViewController(childController: UIViewController, onView: UIView?) {
        var holderView = self.view
        if let onView = onView {
            holderView = onView
        }
        self.addChildViewController(childController)
        childController.view.frame = onView!.bounds
        holderView.addSubview(childController.view)
        childController.didMoveToParentViewController(self)
    }
    
    func removeChildController(childController: UIViewController) {
        childController.willMoveToParentViewController(self)
        childController.view.removeFromSuperview()
        childController.removeFromParentViewController()
    }
}