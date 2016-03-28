//
//  Attachment.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class Attachment: Model {
    dynamic var file_url = ""
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
                
        self.id <- map.property("id")
        self.file_url <- map.property("file_url")
    }
}