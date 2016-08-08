//
//  ConfigHepler.swift
//  Maplify
//
//  Created by Sergey on 2/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class ConfigHepler {
    
    // MARK: - Production mode
    class func isProduction() -> Bool {
        return NSProcessInfo.processInfo().environment[Config.production] == "true"
    }
    
    // MARK: - config parameters
    class func configPlist() -> NSDictionary! {
        let file = (self.isProduction()) ? Config.productionConfigFile : Config.stagingConfigFile
        if let plistPath = NSBundle.mainBundle().pathForResource(file, ofType: FileType.plist) {
            return NSDictionary(contentsOfFile: plistPath)
        }
        return nil
    }
    
    class func baseHostUrl() -> String {
        let configDictionary = self.configPlist()
        return configDictionary.valueForKey("base_host_url") as! String
    }
    
    class func googleProjectKey() -> String {
        let configDictionary = self.configPlist()
        return configDictionary.valueForKey("maplify_google_key") as! String
    }
    
    class func mixpanelToken() -> String {
        let configDictionary = self.configPlist()
        return configDictionary.valueForKey("mixpanel_token") as! String
    }
    
    // MARK: - screen settings
    class func screenSmallerThanIPhoneSixSize() -> Bool {
        return UIScreen.mainScreen().bounds.size.height < ScreenSize.iPhoneSixScreenPointsHeight
    }
}