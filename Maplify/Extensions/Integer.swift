//
//  Integer.swift
//  Maplify
//
//  Created by Sergey on 3/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension Bool {
    init<T : IntegerType>(_ integer: T) {
        if integer == 0 {
            self.init(false)
        } else {
            self.init(true)
        }
    }
}