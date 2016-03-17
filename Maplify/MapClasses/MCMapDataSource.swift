//
//  MCMapDataSource.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

protocol MCMapDataSourceDelegate {
    func numberOfGroups() -> Int
    func numberOfMapItemsForGroup(groupIndex: Int) -> Int
    func mapItem(mapView: MCMapView, indexPath: NSIndexPath) -> MCMapItem
}

class MCMapDataSource {
    var mapView: MCMapView! = nil
    var mapService: MCMapService! = nil
    var delegate: MCMapDataSourceDelegate! = nil

    func reloadMapView() {
        self.mapService.removeAllItems()
        
        var i: Int = 0
        var j: Int = 0
        let numberOfGroups: Int = (self.delegate?.numberOfGroups())!
        
        for _ in 0...numberOfGroups {
            let numberOfItems = (self.delegate?.numberOfMapItemsForGroup(i))!
            for _ in 0...numberOfItems {
                let indexPath = NSIndexPath(forRow: i, inSection: j)
                let mapItem = self.delegate?.mapItem(self.mapView, indexPath: indexPath)
                self.mapService.placeItem(mapItem!)
                j++
            }
            i++
        }
    }
}