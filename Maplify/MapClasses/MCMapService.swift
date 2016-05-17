//
//  MCMapService.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

protocol MCMapServiceProtocol {
    func configuredMapView(region: MCMapRegion, zoom: Float, showWholeWorld: Bool) -> UIView!
    func addItemsGroup(itemsGroup: MCMapItemsGroup)
    func placeItem(item: MCMapItem)
    func removeAllItems()
    func setMapType<T>(mapType: T)
    func moveTo(region: MCMapRegion, zoom: Float)
    func moveToDefaultRegion()
}

@objc protocol MCMapServiceDelegate {
    optional func didTapMapView(mapView: UIView, itemObject: AnyObject)
    optional func didMoveMapView(mapView: UIView, target: AnyObject)
    optional func willMoveMapView(mapView: UIView, willMove: Bool)
    optional func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double)
    optional func didLongTapMapView(mapView: UIView, latitude: Double, longitude: Double)
}

class MCMapService: NSObject, MCMapServiceProtocol {
    var mapView: UIView! = nil
    var defaultRegion: MCMapRegion! = nil
    var defaultZoom: Float! = nil
    var delegate: MCMapServiceDelegate! = nil
    lazy var itemsArray = [MCMapItemsGroup]()

    init(region: MCMapRegion, zoom: Float, showWholeWorld: Bool) {
        super.init()
        self.defaultRegion = region
        self.defaultZoom = zoom
        self.mapView = self.configuredMapView(region, zoom: zoom, showWholeWorld: showWholeWorld)
    }
    
    // MARK: - methods to override
    func configuredMapView(region: MCMapRegion, zoom: Float, showWholeWorld: Bool) -> UIView! {
        return nil
    }
    
    func addItem(item: MCMapItem, indexPath: NSIndexPath) {}
    func addItemsGroup(itemsGroup: MCMapItemsGroup) {}
    func placeItem(item: MCMapItem) {}
    func removeAllItems() {}
    func setMapType<T>(mapType: T) {}
    func moveTo(region: MCMapRegion, zoom: Float) {}
    func moveToDefaultRegion() {}
}