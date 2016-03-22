//
//  NSData.swift
//  Maplify
//
//  Created by Sergey on 3/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension NSData {
    func jsonDictionary() -> AnyObject! {
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(self, options:NSJSONReadingOptions(rawValue: 0))
            guard let _ :NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return nil
            }
            return JSON
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        return nil
    }
}