//
//  GoogleMapService.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

class GoogleMapService: MCMapService, GMSMapViewDelegate {
    
    // MARK: - MCMapServiceProtocol
    override func configuredMapView(region: MCMapRegion, zoom: Float) -> UIView! {
        let camera = GMSCameraPosition.cameraWithLatitude(region.location.latitude, longitude:region.location.longitude, zoom: zoom)
        let mapView = GMSMapView.mapWithFrame(region.span.rect, camera:camera)
        mapView.delegate = self
        return mapView
    }
    
    override func addItemsGroup(itemsGroup: MCMapItemsGroup) {
        self.itemsArray.append(itemsGroup)
    }
    
    override func placeItem(item: MCMapItem) {
        let position = CLLocationCoordinate2DMake(item.location.latitude, item.location.longitude)
        let marker = GMSMarker(position: position)
        marker.title = item.title
        marker.map = self.mapView as? GMSMapView
        marker.icon = item.image
        marker.opacity = Float(item.opacity)
    }
    
    override func removeAllItems() {
        (self.mapView as? GMSMapView)?.clear()
    }
    
    override func setMapType<T>(mapType: T) {
        let type = mapType as! GMSMapViewType
        (self.mapView as! GMSMapView).mapType = type
    }
    
    override func moveTo(region: MCMapRegion, zoom: Float) {
        let camera = GMSCameraPosition.cameraWithLatitude(region.location.latitude, longitude: region.location.longitude, zoom: zoom)
        (self.mapView as! GMSMapView).camera = camera
    }
    
    override func moveToDefaultRegion() {
        let latitude = self.defaultRegion.location.latitude
        let longitude = self.defaultRegion.location.longitude
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: self.defaultZoom)
        (self.mapView as! GMSMapView).camera = camera
    }
    
    // MARK: - MCMapServiceProtocol
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.delegate?.didTapMapView?(mapView, itemObject: marker)
        return true
    }
}