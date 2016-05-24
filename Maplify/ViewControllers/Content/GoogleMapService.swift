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
    override func configuredMapView(region: MCMapRegion, zoom: Float, showWholeWorld: Bool) -> UIView! {
        let initialZoom = showWholeWorld ? kGMSMinZoomLevel : zoom
        let camera = GMSCameraPosition.cameraWithLatitude(region.location.latitude, longitude:region.location.longitude, zoom: initialZoom)
        let mapView = GMSMapView.mapWithFrame(region.span.rect, camera:camera)
        mapView.delegate = self
        return mapView
    }
    
    override func addItemsGroup(itemsGroup: MCMapItemsGroup) {
        self.itemsArray.append(itemsGroup)
    }
    
    override func placeItem(item: MCMapItem) {
        self.placeItem(item, temporary: false)
    }
    
    func placeItem(item: MCMapItem, temporary: Bool) {
        let position = CLLocationCoordinate2DMake(item.location.latitude, item.location.longitude)
        let marker = GMSMarker(position: position)
        marker.title = item.title
        marker.map = self.mapView as? GMSMapView
        marker.icon = item.image
        marker.opacity = Float(item.opacity)
        marker.userData = temporary
        
        item.data = marker
    }
    
    override func removeItem(item: MCMapItem) {
        (item.data as! GMSMarker).map = nil
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
    
    // MARK: - location
    func locationFromTouch(mapView: UIView, point: CGPoint) -> MCMapCoordinate {
        let serviceView = (mapView as! MCMapView).serviceView
        let coordinate = (serviceView as! GMSMapView).projection.coordinateForPoint(point)
        let location = MCMapCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location
    }
    
    func currentZoom() -> Float {
        return (self.mapView as! GMSMapView).camera.zoom
    }
    
    // MARK: - GMSMapViewDelegate
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        self.delegate?.willMoveMapView?(mapView, willMove: gesture)
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        self.delegate?.didMoveMapView?(mapView, target: position)
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.delegate?.didTapMapView?(mapView, itemObject: marker)
        return true
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.delegate?.didTapCoordinateMapView?(mapView, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        let locationInView = mapView.projection.pointForCoordinate(coordinate)
        self.delegate?.didLongTapMapView?(mapView, latitude: coordinate.latitude, longitude: coordinate.longitude, locationInView: locationInView)
    }
}