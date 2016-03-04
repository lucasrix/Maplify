//
//  ConfigHepler.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ConfigHepler {
    
    // MARK: - Production mode
    class func isProduction() -> Bool {
        return NSProcessInfo.processInfo().environment[Config.production] == "true"
    }
    
    class func baseHostUrl() -> String {
        return (self.isProduction()) ? URL.productionHost : URL.stagingHost
    }
    
    // MARK: - config parameters
    class func configPlist() -> NSDictionary! {
        if let plistPath = NSBundle.mainBundle().pathForResource(Config.configFile, ofType: FileType.plist) {
            return NSDictionary(contentsOfFile: plistPath)
        }
        return nil
    }
    
    // MARK: - screen settings
    class func screenSmallerThanIPhoneSixSize() -> Bool {
        return UIScreen.mainScreen().bounds.size.height < ScreenSize.iPhoneSixScreenPointsHeight
    }

}