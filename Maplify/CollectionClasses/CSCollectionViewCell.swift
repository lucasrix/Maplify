//
//  CSCollectionViewCell.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

protocol CSCollectionViewCellProtocol {
    func configure(cellData: CSCellData)
}

class CSCollectionViewCell: UICollectionViewCell, CSCollectionViewCellProtocol {
    func configure(cellData: CSCellData) {
        //override at subclass
    }
}