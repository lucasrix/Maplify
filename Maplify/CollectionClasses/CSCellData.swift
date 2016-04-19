//
//  CSCellData.swift
//  table_classes
//
//  Created by Sergey on 2/22/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

class CSCellData {
    var model: AnyObject! = nil
    var selected: Bool = false
    var cellIdentifier: String! = nil
    var sectionTitle: String! = nil
    var delegate: AnyObject! = nil
    var contentSize: CGSize = CGSizeZero
    var boundingSize: CGSize = CGSizeZero
}