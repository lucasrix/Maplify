//
//  ApiClient.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Alamofire
import SwiftyJSON

typealias successClosure = (response: AnyObject!) -> ()
typealias failureClosure = (statusCode: Int, errors: [ApiError], localDescription: String) -> ()

class ApiClient {
    static let sharedClient = ApiClient()
    
    func request(type: Alamofire.Method, uri: String, params: [String: AnyObject]?, acceptCodes: [String]!, success: successClosure!, failure: failureClosure!) {
        Alamofire.request(type, uri.byAddingHost(), parameters: params)
            .response { request, response, data, error in
//                let a = JSON(data: data!)
                let headersDictionary = (response! as NSHTTPURLResponse).allHeaderFields
                SessionManager.sharedManager.setSessionData(headersDictionary)
        }
    }
    
    func getRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.POST, uri: "auth", params: ["email":"test8@test.test", "password":"12345678", "password_confirmation":"12345678"], acceptCodes: nil, success: nil, failure: nil)
    }
}

private extension String {
    func byAddingHost() -> String {
//        return ConfigHepler.baseHostUrl() + "/api/v1/" + self
        return "http://10.10.10.170:3000" + "/api/v1/" + self
    }
}