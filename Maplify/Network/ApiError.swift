//
//  ApiError.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import SwiftyJSON

class ApiError {
    var errorMessage: String! = nil
    var errorField: String! = nil
    
    init(message: String, field: String) {
        self.errorMessage = message
        self.errorField = field
    }
    
    class func parseErrors(details: [String: AnyObject]!, messages: [AnyObject]!) -> [ApiError] {
        var errors = [ApiError]()

        var index = 0
        for key in details {
            let field = key.0
            let message = key.1[0]
            let error = ApiError(message: message as! String, field: field)
            errors.append(error)
            index++
        }
        
        return errors
    }
}