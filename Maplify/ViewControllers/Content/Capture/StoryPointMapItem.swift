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
        self.location = MCMapCoordinate(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
        self.image = UIImage(named: MapPinImages.base)
    }
}