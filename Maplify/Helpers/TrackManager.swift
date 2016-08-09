//
//  TrackManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 8/8/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class TrackManager {
    class func sharedManager() -> AnalyticsManagerProtocol {
        if ConfigHepler.isProduction() {
            return MixpanelAnalyticsManager()
        }
        return ConsoleAnalyticsManager()
    }
}
