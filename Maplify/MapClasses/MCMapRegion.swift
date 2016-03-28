//
//  MCMapRegion.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

struct MCMapCoordinate {
    var latitude: Double
    var longitude: Double
}

struct MCMapRegionSpan {
    var latitudeDelta: Double
    var longitudeDelta: Double
    var rect: CGRect {
        get {
            return CGRectMake(0, 0, CGFloat(self.latitudeDelta), CGFloat(self.longitudeDelta))
        }
    }
}

class MCMapRegion {
    var location: MCMapCoordinate
    var span: MCMapRegionSpan
    
    init(latitude: Double, longitude: Double) {
        self.location = MCMapCoordinate(latitude: latitude, longitude: longitude)
        self.span = MCMapRegionSpan(latitudeDelta: 0, longitudeDelta: 0)
    }
    
    init(latitude: Double, longitude: Double, span: MCMapRegionSpan) {
        self.location = MCMapCoordinate(latitude: latitude, longitude: longitude)
        self.span = span
    }
}