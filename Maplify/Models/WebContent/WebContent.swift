//
//  WebContent.swift
//  Maplify
//
//  Created by Sergey on 3/14/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class WebContent: Mappable {
    var html: String! = nil
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
        
        self.html <- map.property("html")
    }
}