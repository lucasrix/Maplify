//
//  MapView.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class MCMapView: UIView {
    var serviceView: UIView! = nil
    
    var service: MCMapService! {
        didSet {
            self.configure(service)
        }
    }
    
    func configure(service: MCMapService!) {
        self.serviceView = service.mapView
        self.serviceView.frame = self.bounds
        self.addSubview(self.serviceView)
    }
}
