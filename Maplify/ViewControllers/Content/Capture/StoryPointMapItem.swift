//
//  StoryPointMapItem.swift
//  Maplify
//
//  Created by Sergey on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class StoryPointMapItem: MCMapItem {
    override func configure(data: CSCellData) {
        let storyPoint = data.model as! StoryPoint
        
        self.setupLocation(storyPoint.location)
        self.setupImage(storyPoint.kind)
    }
    
    func setupLocation(location: Location) {
        self.location = MCMapCoordinate(latitude: location.latitude, longitude: location.longitude)
    }
    
    func setupImage(type: String) {
        if type == StoryPointKind.Audio.rawValue {
            self.image = UIImage(named: MapPinImages.audio)
        } else if type == StoryPointKind.Text.rawValue {
            self.image = UIImage(named: MapPinImages.text)
        } else if type == StoryPointKind.Video.rawValue {
            self.image = UIImage(named: MapPinImages.video)
        } else if type == StoryPointKind.Photo.rawValue {
            self.image = UIImage(named: MapPinImages.video)
        } else {
            self.image = UIImage(named: MapPinImages.base)
        }
    }
}