//
//  UIBarButtonItem.swift
//  Maplify
//
//  Created by Sergei on 08/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kDefaultNavBarItemEdge: CGFloat = 30

extension UIBarButtonItem {
    class func barButton(image: UIImage, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .Custom)
        button.tintColor = UIColor.clearColor()
        button.frame = CGRectMake(0, 0, kDefaultNavBarItemEdge, kDefaultNavBarItemEdge)
        button.setImage(image, forState: .Normal)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: button)
    }
}