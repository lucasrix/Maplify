//
//  CameraRollItemViewCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class CameraRollItemViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
}
