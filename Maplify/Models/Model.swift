//
//  Model.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import Tailor

class Model : RealmSwift.Object, Mappable {
    dynamic var created_at = ""
    dynamic var updated_at = ""
    
    required init() {
        super.init()
    }
    
    convenience required init(_ map: [String : AnyObject]) {
        self.init()
    }
}