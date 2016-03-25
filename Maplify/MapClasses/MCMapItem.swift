//
//  MCMapItem.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kDefaulMapItemOpacity: CGFloat = 1

protocol MCMapItemProtocol {
    func configure(data: CSCellData)
}

class MCMapItem: MCMapItemProtocol {
    var location: MCMapCoordinate! = nil
    var title: String! = nil
    var image: UIImage! = nil
    var opacity: CGFloat = kDefaulMapItemOpacity

    required init() {}
    
    func configure(data: CSCellData) {}
}