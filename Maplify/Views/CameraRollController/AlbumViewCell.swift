//
//  AlbumViewCell.swift
//  CameraRoll
//
//  Created by Evgeniy Antonoff on 3/29/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import UIKit
import Photos

let kTimeBackVieweCrRadius: CGFloat = 3

class AlbumViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeBackView: UIView!
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.timeBackView.layer.cornerRadius = kTimeBackVieweCrRadius
        }
    }
}
