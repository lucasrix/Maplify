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
    
    // MARK: - realm list type support
    class func arrayToList<T: Object>(array: [T]?, type: T.Type) -> List<T> {
        let list = List<T>()
        for object in array! {
            list.append(object)
        }
        return list
    }
    
    class func listToArray<T: Object>(list: List<T>, type: T.Type) -> [T] {
        var array = [T]()
        for object in list {
            array.append(object)
        }
        return array
    }
}

