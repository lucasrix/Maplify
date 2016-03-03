//
//  ApiRequest.swift
//  Maplify
//
//  Created by Sergey on 3/2/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Alamofire

struct RequestConfig {
    var type: Alamofire.Method
    var uri: String
    var params: [String: AnyObject]!
    var acceptCodes: [Int]!
    var data: [String: AnyObject]!
    var progress: progressClosure!
    
    init(type: Alamofire.Method, uri: String, params: [String: AnyObject], acceptCodes: [Int]!, data: [String: AnyObject]!) {
        self.type = type
        self.uri = uri
        self.params = params
        self.acceptCodes = acceptCodes
        self.data = data
    }
}