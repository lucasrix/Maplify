//
//  CaptureMCMapServiceExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

extension CaptureViewController {
    
    // MARK: - MCMapServiceDelegate
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        if ((itemObject as! GMSMarker).userData as! Bool) == false {
            let clLocation = (itemObject as! GMSMarker).position
            let pointInView = self.googleMapService.pointFromLocation(clLocation)
            
            let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
            let storyPointIndex = self.mapActiveModel.storyPointIndex(mapCoordinate, section: 0)
            
            self.infiniteScrollView.hidden = false
            
            self.selectPin(storyPointIndex, mapCoordinate: mapCoordinate, pointInView: pointInView)
        }
        self.popTip?.hide()
    }
    
    func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double) {
        self.infiniteScrollView.hidden = true
        self.removePreviewItem()
        self.mapActiveModel.deselectAll()
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func didLongTapMapView(mapView: UIView, latitude: Double, longitude: Double, locationInView: CGPoint) {
        if self.contentType == .Default {
            self.pressAndHoldView.hidden = true
            self.pressAndHoldLabel.hidden = true
            let coordinate = MCMapCoordinate(latitude: latitude, longitude: longitude)
            self.removePreviewItem()
            let placeItem = MCMapItem()
            placeItem.location = coordinate
            placeItem.image = UIImage(named: MapPinImages.tapped)
            
            self.previewPlaceItem = placeItem
            self.googleMapService.placeItem(placeItem, temporary: true)
            
            self.configuratePopup(locationInView, coordinate: coordinate)
        }
    }
    
    func willMoveMapView(mapView: UIView, willMove: Bool) {
        self.removePreviewItem()
    }
}
