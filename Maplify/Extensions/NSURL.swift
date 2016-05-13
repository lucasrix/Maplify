//
//  NSUrl.swift
//  Maplify
//
//  Created by Sergei on 06/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kPrefixHttp = "http://"

extension NSURL {
    var queryItems: [String: String] {
        return (NSURLComponents(URL: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], combine: { (params: [String: String], item) -> [String: String] in
                var data = params
                data[item.name] = item.value
                return data
            }))!
    }
    
    func byAddingPrefixIfNeeded() -> NSURL {
        if String(self).hasPrefix(kPrefixHttp) == false {
            return NSURL(string: kPrefixHttp + String(self))!
        }
        return self
    }
}