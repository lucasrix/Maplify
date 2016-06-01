//
//  CaptureMapExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 6/1/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps

extension CaptureViewController: MCMapServiceDelegate {
    func checkLocationEnabled(completion: (() -> ())!) {
        if SessionHelper.sharedHelper.locationEnabled() && self.contentType == .Default {
            self.retrieveCurrentLocation({ [weak self] (location) in
                completion()
                if location != nil {
                    SessionHelper.sharedHelper.updateUserLastLocationIfNeeded(location)
                    self?.setupMap(location, showWholeWorld: false)
                } else {
                    self?.setupMap(SessionHelper.sharedHelper.userLastLocation(), showWholeWorld: true)
                }
            })
        } else {
            let defaultLocation = CLLocation(latitude: DefaultLocation.washingtonDC.0, longitude: DefaultLocation.washingtonDC.1)
            self.setupMap(defaultLocation, showWholeWorld: true)
        }
    }
    
    func retrieveCurrentLocation(completion: ((location: CLLocation!) -> ())!) {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { (location, accuracy, status) -> () in
            completion(location: location)
        }
    }
    
    func setupMap(location: CLLocation, showWholeWorld: Bool) {
        let region = MCMapRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.googleMapService = GoogleMapService(region: region, zoom: kDefaulMapZoom, showWholeWorld: showWholeWorld)
        self.googleMapService.setMapType(kGMSTypeNormal)
        self.googleMapService.delegate = self
        self.mapView.service = self.googleMapService
    }
    
    func selectPin(index: Int, mapCoordinate: MCMapCoordinate, pointInView: CGPoint) {
        if index != NSNotFound {
            self.captureActiveModel.selectPinAtIndex(index)
            self.captureDataSource.reloadMapView(StoryPointMapItem)
            self.infiniteScrollView.moveAndShowCell(index, animated: false)
            if self.contentType == .Story {
                self.infiniteScrollView.moveAndShowCell(index + 1, animated: false)
            } else {
                self.infiniteScrollView.moveAndShowCell(index, animated: false)
            }
            self.scrollToDestinationPointWithOffset(pointInView)
        }
    }
    
    // MARK: - MCMapServiceDelegate
    func didTapMapView(mapView: UIView, itemObject: AnyObject) {
        if ((itemObject as! GMSMarker).userData as! Bool) == false {
            let clLocation = (itemObject as! GMSMarker).position
            let pointInView = self.googleMapService.pointFromLocation(clLocation)
            
            let mapCoordinate = MCMapCoordinate(latitude: clLocation.latitude, longitude: clLocation.longitude)
            let storyPointIndex = self.captureActiveModel.storyPointIndex(mapCoordinate, section: 0)
            
            self.infiniteScrollView.hidden = false
            
            self.selectPin(storyPointIndex, mapCoordinate: mapCoordinate, pointInView: pointInView)
        }
        self.popTip?.hide()
    }
    
    func willMoveMapView(mapView: UIView, willMove: Bool) {
        self.removePreviewItem()
    }
    
    func didTapCoordinateMapView(mapView: UIView, latitude: Double, longitude: Double) {
        self.infiniteScrollView.hidden = true
        self.removePreviewItem()
        self.captureActiveModel.deselectAll()
        self.captureDataSource.reloadMapView(StoryPointMapItem)
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
}
