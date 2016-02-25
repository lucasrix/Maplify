//
//  CSTableViewCell.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

@objc protocol CSTableViewCellProtocol {
    optional func configure(cellData: AnyObject)
}

class CSTableViewCell: UITableViewCell, CSTableViewCellProtocol {
    func configure(cellData: AnyObject) {
        //override at subclass
    }
}