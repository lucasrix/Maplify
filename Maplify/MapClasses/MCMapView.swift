//
//  MapView.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class MCMapView: UIView {
    var service: MCMapService! {
        didSet {
            self.configure(service)
        }
    }
    
    func configure(service: MCMapService!) {
        service.mapView.frame = self.bounds
        self.addSubview(service.mapView)
    }
}
