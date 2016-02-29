//
//  ApiError.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class ApiError {
    var errorMessage: String! = nil
    var errorField: String! = nil
    
    init(message: String, field: String) {
        self.errorMessage = message
        self.errorField = field
    }
}