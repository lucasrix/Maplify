//
//  CapturePopUpView.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import GoogleMaps

class CapturePopUpView: UIView {
    @IBOutlet weak var addressLabel: UILabel!
    
    var view: UIView! = nil
    var location: MCMapCoordinate! = nil
    var address = String()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        self.view = NSBundle.mainBundle().loadNibNamed(String(CapturePopUpView), owner: self, options: nil).first as? UIView
        if (self.view != nil) {
            self.view.frame = bounds
            self.addSubview(self.view)
            self.addressLabel.text = NSLocalizedString("Label.Loading", comment: String())
        }
    }
    
    func configure(location: MCMapCoordinate!, completion: ((locationString: String) -> ())!) {
        self.retrievePlace(location, completion: completion)
    }
    
    // MARK: - location
    func retrievePlace(location: MCMapCoordinate!, completion: ((locationString: String) -> ())!) {
        if location != nil {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            GeocoderHelper.placeFromCoordinate(coordinate) { [weak self] (addressString) in
                self?.addressLabel.text = addressString
            }
        }
    }
    
    func generateLocationString(location: MCMapCoordinate!) -> String {
        if location != nil {
            return String(format: NSLocalizedString("Label.LatitudeLongitude", comment: String()), location.latitude, location.longitude)
        }
        return String()
    }
}
