//
//  StoryboardHelper.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class func authStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Auth", bundle: nil)
    }
}