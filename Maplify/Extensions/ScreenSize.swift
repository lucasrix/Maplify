//
//  ScreenSize.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/19/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let iPhoneScreenSizeHeight3_5: CGFloat = 480
let iPhoneScreenSizeHeight4_0: CGFloat = 568
let iPhoneScreenSizeHeight4_7: CGFloat = 667
let iPhoneScreenSizeHeight5_5: CGFloat = 736

extension UIScreen {
    func isIPhoneScreenSize3_5() -> Bool {
        return UIScreen.mainScreen().bounds.height == iPhoneScreenSizeHeight3_5
    }
    
    func isIPhoneScreenSize4_0() -> Bool {
        return UIScreen.mainScreen().bounds.height == iPhoneScreenSizeHeight4_0
    }
    
    func isIPhoneScreenSize4_7() -> Bool {
        return UIScreen.mainScreen().bounds.height == iPhoneScreenSizeHeight4_7
    }
    
    func isIPhoneScreenSize5_5() -> Bool {
        return UIScreen.mainScreen().bounds.height == iPhoneScreenSizeHeight5_5
    }
    
    func screenWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
}
