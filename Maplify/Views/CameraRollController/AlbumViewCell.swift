//
//  AlbumViewCell.swift
//  CameraRoll
//
//  Created by Evgeniy Antonoff on 3/29/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import UIKit
import Photos

class AlbumViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
}
