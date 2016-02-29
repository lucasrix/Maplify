//
//  ApiClient.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Alamofire
import SwiftyJSON

typealias successClosure = (response: [String: AnyObject]!) -> ()
typealias failureClosure = (statusCode: Int, errors: [ApiError]!, localDescription: String!) -> ()

class ApiClient {
    static let sharedClient = ApiClient()
    
    // MARK: - request management
    private func request(type: Alamofire.Method, uri: String, params: [String: AnyObject]?, acceptCodes: [Int]!, success: successClosure!, failure: failureClosure!) {
        let headers = SessionManager.sharedManager.sessionData() as! [String : String]
        Alamofire.request(type, uri.byAddingHost(), parameters: params, encoding: .JSON, headers: headers)
            .response {[weak self] request, response, data, error  in
                let headersDictionary = (response! as NSHTTPURLResponse).allHeaderFields
                if headersDictionary["Access-Token"] != nil {
                    SessionManager.sharedManager.setSessionData(headersDictionary)
                }
                
                let payload = JSON(data: data!).dictionaryObject
                let statusCode = (response! as NSHTTPURLResponse).statusCode
                if acceptCodes.contains(statusCode) {
                    if let dataDictionary = payload!["data"] {
                        dispatch_async(dispatch_get_main_queue()) {
                            success?(response: dataDictionary as! [String : AnyObject])
                        }
                    }
                } else {
                    self?.handleError(payload!, statusCode: statusCode, error: error, failure: failure)
                }
        }
    }
    
    private func handleError(payload: [String : AnyObject], statusCode: Int , error: NSError!, failure: failureClosure!) {
        let details = payload["error"]!["details"] as! [String : AnyObject]
        let messages = payload["error"]!["error_messages"] as! [String]
        let errors = ApiError.parseErrors(details, messages: messages)
        
        dispatch_async(dispatch_get_main_queue()) {
            failure?(statusCode: statusCode, errors: errors, localDescription: error?.localizedDescription)
        }
    }
    
    func postRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.POST, uri: uri, params: params, acceptCodes: [Network.successStatusCode], success: success, failure: failure)
    }
    
    func getRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.GET, uri: uri, params: params, acceptCodes: [Network.successStatusCode], success: success, failure: failure)
    }
    
    func putRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.PUT, uri: uri, params: params, acceptCodes: [Network.successStatusCode], success: success, failure: failure)
    }
    
    func deleteRequest(uri: String, params: [String: AnyObject]?, success: successClosure!, failure: failureClosure!) {
        self.request(.DELETE, uri: uri, params: params, acceptCodes: [Network.successStatusCode], success: success, failure: failure)
    }
    
    // MARK: - user methods
    func signUp(email: String, password: String, passwordConfirmation: String, success: successClosure!, failure: failureClosure!) {
        self.postRequest("auth", params:  ["email":email, "password":password, "password_confirmation":passwordConfirmation], success: success, failure: failure)
    }
}

private extension String {
    func byAddingHost() -> String {
        return ConfigHepler.baseHostUrl() + "/api/v1/" + self
    }
}