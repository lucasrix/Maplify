//
//  ColorUtils.swift
//  table_classes
//
//  Created by Sergey on 2/23/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    class func defaultBlueColor() -> UIColor {
        return UIColor(red: 42, green: 173, blue: 255)
    }
    
    class func defaultGreyColor() -> UIColor {
        return UIColor(red: 45, green: 45, blue: 45)
    }
    
    class func defaultRedColor() -> UIColor {
        return UIColor(red: 108, green: 28, blue: 38)
    }
    
    class func warmGrey() -> UIColor {
        return UIColor(red: 155, green: 155, blue: 155)
    }
    
    class func dodgerBlue() -> UIColor {
        return UIColor(red: 53, green: 175, blue: 255)
    }
    
    class func lightishRed() -> UIColor {
        return UIColor(red: 255, green: 55, blue: 79)
    }
}
