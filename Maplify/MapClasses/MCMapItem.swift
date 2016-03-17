//
//  MCMapItem.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kDefaulMapItemOpacity: CGFloat = 1

class MCMapItem {
    var location: MCMapCoordinate! = nil
    var title: String! = nil
    var image: UIImage! = nil
    var opacity: CGFloat = kDefaulMapItemOpacity
    
    init(location: MCMapCoordinate, title: String!, image: UIImage!) {
        self.location = location
        self.title = title
        self.image = image
    }
}