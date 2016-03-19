//
//  MainViewController.swift
//  Maplify
//
//  Created by Sergey on 3/17/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import GoogleMaps

class ContentViewController: ViewController, StoryPointCreationPopupDelegate {
    @IBOutlet weak var mapView: MCMapView!
    
    @IBAction func createStoryPointTapped(sender: UIButton) {
        self.routesShowPopupStoryPointCreationController(self)
    }
    
    //MARK: - StoryPointCreationPopupDelegate
    func ambientDidTapped() {
        
    }
    
    func photoVideoDidTapped() {
        
    }
    
    func textDidTapped() {
        
    }
}