//
//  RelationOrNil.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor
import Sugar

public extension Dictionary {

    func relationOrNil<T : Mappable>(name: String) -> T? {
        let value = self[name as! Key]
        if !(value is NSNull) && value != nil {
            let dictionary = value as? JSONDictionary
            return T(dictionary!)
        } else {
            return nil
        }
    }
    
    func boolProperty(name: String) -> Bool {
        let value = self[name as! Key]
        return Bool(value as! Int)
    }
}