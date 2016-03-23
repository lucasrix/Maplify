//
//  CSTableViewCell.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

protocol CSTableViewCellProtocol {
    func configure(cellData: CSCellData)
}

class CSTableViewCell: UITableViewCell, CSTableViewCellProtocol {
    func configure(cellData: CSCellData) {
        //override at subclass
    }
}