//
//  CSCollectionViewCell.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

@objc protocol CSCollectionViewCellProtocol {
    optional func configure(cellData: AnyObject)
}

class CSCollectionViewCell: UICollectionViewCell, CSCollectionViewCellProtocol {
    func configure(cellData: AnyObject) {
        //override at subclass
    }
}