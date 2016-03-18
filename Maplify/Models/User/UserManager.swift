//
//  UserManager.swift
//  Maplify
//
//  Created by Sergey on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class UserManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        return User(response)
    }
}