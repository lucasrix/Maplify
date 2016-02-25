//
//  ConfigHepler.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ConfigHepler {
    class func isProduction() -> Bool {
        return NSProcessInfo.processInfo().environment["PRODUCTION"] == "true"
    }
}