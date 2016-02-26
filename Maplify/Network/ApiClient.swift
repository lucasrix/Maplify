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
    
    // MARK: - request management
    func request(type: Alamofire.Method, uri: String, params: [String: AnyObject]?, acceptCodes: [String]!, success: successClosure!, failure: failureClosure!) {
        Alamofire.request(type, uri.byAddingHost(), parameters: params)
            .response { request, response, data, error in
//                let a = JSON(data: data!)
                let headersDictionary = (response! as NSHTTPURLResponse).allHeaderFields
                SessionManager.sharedManager.setSessionData(headersDictionary)
        }
    }
    
    func postRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.POST, uri: uri, params: params, acceptCodes: nil, success: success, failure: failure)
    }
    
    func getRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.GET, uri: uri, params: params, acceptCodes: nil, success: success, failure: failure)
    }
    
    func putRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.PUT, uri: uri, params: params, acceptCodes: nil, success: success, failure: failure)
    }
    
    func deleteRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.DELETE, uri: uri, params: params, acceptCodes: nil, success: success, failure: failure)
    }
    
    // MARK: - user methods
    func signUp(email: String, password: String, passwordConfirmation: String, success: successClosure!, failure: failureClosure!) {
        self.postRequest("auth", params:  ["email":email, "password":password, "password_confirmation":passwordConfirmation], success: success, failure: failure)
    }
}

private extension String {
    func byAddingHost() -> String {
//        return ConfigHepler.baseHostUrl() + "/api/v1/" + self
        return "http://10.10.10.170:3000" + "/api/v1/" + self
    }
}