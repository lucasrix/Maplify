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
    
    class func parseErrors(details: [String : AnyObject], messages: [String]) -> [ApiError] {
        var errors = [ApiError]()

        var index = 0
        for key in details {
            let field = key.0
            let message = messages[index]
            let error = ApiError(message: message, field: field)
            errors.append(error)
            index++
        }
        
        return errors
    }
}