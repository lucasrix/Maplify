//
//  ApiError.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class ApiError {
    var errorMessage: String! = nil
    var errorField: String! = nil
    
    init(message: String, field: String) {
        self.errorMessage = message
        self.errorField = field
    }
    
    class func parseErrors(details: [String: AnyObject]!, messages: [AnyObject]!) -> [ApiError] {
        var errors = [ApiError]()

        for key in details {
            let field = key.0
            let message = key.1.firstObject as! String
            let error = ApiError(message: message, field: field)
            errors.append(error)
        }
        return errors
    }
}