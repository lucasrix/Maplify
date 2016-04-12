//
//  Converter.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Converter {
    class func arrayToList<T: Object>(array: [T]?, type: T.Type) -> List<T> {
        let list = List<T>()
        for object in array! {
            list.append(object)
        }
        return list
    }    
}

