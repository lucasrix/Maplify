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
    var mapActiveModel: CSActiveModel! = nil
    var delegate: AnyObject! = nil
    
    func reloadMapView<T: MCMapItem>(type: T.Type) {
        if self.mapService != nil {
            self.mapService.removeAllItems()
            
            for i in 0..<self.mapActiveModel.numberOfSections() {
                for j in 0..<self.mapActiveModel.numberOfItems(i) {
                    let indexPath = NSIndexPath(forRow: j, inSection: i)
                    let data = self.mapActiveModel.cellData(indexPath)
                    if (data != nil) && (data.model is StoryPoint) {
                        let mapItem = T()
                        mapItem.configure(data)
                        self.mapService.placeItem(mapItem)
                    }
                }
            }
        }
    }
}