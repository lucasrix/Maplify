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
    
    class func windowsBlue() -> UIColor {
        return UIColor(red: 55, green: 97, blue: 183)
    }
    
    class func cornflowerBlue() -> UIColor {
        return UIColor(red: 69, green: 115, blue: 210)
    }
    
    class func waterBlue() -> UIColor {
        return UIColor(red: 16, green: 146, blue: 223)
    }
    
    class func lightishRed() -> UIColor {
        return UIColor(red: 255, green: 55, blue: 79)
    }
    
    class func inactiveWhite() -> UIColor {
        return UIColor(red: 255, green: 255, blue: 255).colorWithAlphaComponent(0.15)
    }
    
    class func activeWhite() -> UIColor {
        return UIColor(red: 255, green: 255, blue: 255).colorWithAlphaComponent(0.35)
    }
    
    class func waterMelon() -> UIColor {
        return UIColor(red: 255, green: 77, blue: 99)
    }
    
    class func darkGreyBlue() -> UIColor {
        return UIColor(red: 54, green: 75, blue: 97)
    }
    
    class func darkBlueGrey() -> UIColor {
        return UIColor(red: 18, green: 42, blue: 66)
    }
}
