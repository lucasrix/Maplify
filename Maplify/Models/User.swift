//
//  User.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift

class User: Object {
    dynamic var id = ""
    dynamic var uid = ""
    dynamic var provider = ""
    dynamic var name = ""
    dynamic var nickname = ""
    dynamic var email = ""
    dynamic var image = ""
}