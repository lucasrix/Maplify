//
//  Model.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class Model : RealmSwift.Object {
    dynamic var created_at: NSData! = nil
    dynamic var updated_at: NSData! = nil
}