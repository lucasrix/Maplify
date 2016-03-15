//
//  ApiClient.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Tailor

typealias successClosure = (response: AnyObject!) -> ()
typealias failureClosure = (statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) -> ()
typealias progressClosure = (Int64, Int64, Int64) -> ()

class ApiClient {
    static let sharedClient = ApiClient()
    
    // MARK: - request management
    private func request<T: Mappable>(config: RequestConfig, map: T.Type, success: successClosure!, failure: failureClosure!) {
        if (config.data != nil) {
            self.dataRequest(config, map: map, success: success, failure: failure)
        } else {
            self.baseRequest(config, map: map, success: success, failure: failure)
        }
    }
    
    private func baseRequest<T: Mappable>(config: RequestConfig, map: T.Type, success: successClosure!, failure: failureClosure!) {
        let headers = SessionManager.sharedManager.sessionData() as! [String: String]
        Alamofire.request(config.type, config.uri.byAddingHost(), parameters: config.params, encoding: .JSON, headers: headers)
            .response {[weak self] request, response, data, error  in
                self?.manageResponse(response!, data: data!, map: map, acceptCodes: config.acceptCodes, error: error, success: success, failure: failure)
        }
    }
    
    private func dataRequest<T: Mappable>(config: RequestConfig, map: T.Type, success: successClosure!, failure: failureClosure!) {
        let headers = SessionManager.sharedManager.sessionData() as! [String: String]
        
        Alamofire.upload(config.type, config.uri.byAddingHost(), headers: headers,
            multipartFormData: { (multipartFormData) -> () in
                let data = config.data[0].value as! NSData
                let name = config.data[0].key
                let fileName = config.params["fileName"]
                let mimeType = config.params["mimeType"]
                multipartFormData.appendBodyPart(data: data, name: name, fileName: fileName as! String, mimeType: mimeType as! String)
                
                for (key, value) in config.params {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            },
            encodingCompletion: { (multipartFormDataEncodingResult) -> () in
                switch multipartFormDataEncodingResult {
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                        dispatch_async(dispatch_get_main_queue()) {
                            config.progress?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
                        }
                    }
                    upload.response(completionHandler: { [weak self] (request, response, data, error) -> () in
                        self?.manageResponse(response!, data: data!, map: map, acceptCodes: config.acceptCodes, error: error, success: success, failure: failure)
                    })
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    private func manageResponse<T: Mappable>(response: NSHTTPURLResponse!, data: NSData!, map: T.Type, acceptCodes: [Int]!, error: NSError!, success: successClosure!, failure: failureClosure!) {
        let headersDictionary = (response as NSHTTPURLResponse).allHeaderFields
        if headersDictionary["Access-Token"] != nil {
            SessionManager.sharedManager.setSessionData(headersDictionary)
        }
        
        var payload = JSON(data: data).dictionaryObject
        if payload == nil {
            let str = String(data: data, encoding: NSUTF8StringEncoding)
            let htmlDict = ["html": str!] as NSDictionary
            payload = ["data": htmlDict]
        }
        let statusCode = (response as NSHTTPURLResponse).statusCode
        if acceptCodes.contains(statusCode) {
            if let dataDictionary = payload!["data"] {
                dispatch_async(dispatch_get_main_queue()) {
                    success?(response: T(dataDictionary as! [String : AnyObject]) as! AnyObject)
                }
            }
        } else {
            self.handleError(payload!, statusCode: statusCode, error: error, failure: failure)
        }
    }
    
    private func handleError(payload: [String: AnyObject]!, statusCode: Int , error: NSError!, failure: failureClosure!) {
        let errorDict = payload["error"] as! [String: AnyObject]
        let details = errorDict["details"] as! [String: AnyObject]
        let messages = errorDict["error_messages"] as! [String]
        
        let errors = ApiError.parseErrors(details, messages: messages)
        
        dispatch_async(dispatch_get_main_queue()) {
            failure?(statusCode: statusCode, errors: errors, localDescription: error?.localizedDescription, messages: messages)
        }
    }
    
    func postRequest<T: Mappable>(uri: String, params: [String: AnyObject]?, data: [String: AnyObject]!, map: T.Type, progress: progressClosure!, success: successClosure!, failure: failureClosure!) {
        let config = RequestConfig(type: .POST, uri: uri, params: params!, acceptCodes: Network.successStatusCodes, data: data)
        self.request(config, map: map, success: success, failure: failure)
    }
    
    func getRequest<T: Mappable>(uri: String, params: [String: AnyObject]?, map: T.Type, success: successClosure!, failure: failureClosure!) {
        let config = RequestConfig(type: .GET, uri: uri, params: params, acceptCodes: Network.successStatusCodes, data: nil)
        self.request(config, map: map, success: success, failure: failure)
    }
    
    func putRequest<T: Mappable>(uri: String, params: [String: AnyObject]?, map: T.Type, success: successClosure!, failure: failureClosure!) {
        let config = RequestConfig(type: .PUT, uri: uri, params: params!, acceptCodes: Network.successStatusCodes, data: nil)
        self.request(config, map: map, success: success, failure: failure)
    }
    
    func deleteRequest<T: Mappable>(uri: String, params: [String: AnyObject]?, map: T.Type, success: successClosure!, failure: failureClosure!) {
        let config = RequestConfig(type: .DELETE, uri: uri, params: params!, acceptCodes: Network.successStatusCodes, data: nil)
        self.request(config, map: map, success: success, failure: failure)
    }
    
    // MARK: - user methods
    func signUp(user: User, password: String, passwordConfirmation: String, photo: NSData!, success: successClosure!, failure: failureClosure!) {
        let params = ["email": user.email, "password": password, "password_confirmation": passwordConfirmation, "mimeType": "image/png", "fileName": "photo.png"]
        var data: [String: AnyObject]! = nil
        if (photo != nil) {
            data = ["photo": photo]
        }
        self.postRequest("auth", params: params, data: data, map: User.self, progress: nil, success: success, failure: failure)
    }
    
    func signIn(email: String, password: String, success: successClosure!, failure: failureClosure!) {
        let params = ["email": email, "password": password]
        self.postRequest("auth/sign_in", params: params, data: nil, map: User.self, progress: nil, success: success, failure: failure)
    }
    
    func facebookAuth(token: String, success: successClosure!, failure: failureClosure!) {
        let params = ["facebook_access_token": token]
        self.postRequest("auth/provider_sessions", params:params , data: nil, map: User.self, progress: nil, success: success, failure: failure)
    }
    
    func updateProfile(profile: Profile, success: successClosure!, failure: failureClosure!) {
        let params = ["city": profile.city, "url": profile.url, "about": profile.about, "first_name": profile.firstName, "last_name": profile.lastName]
        self.putRequest("profile", params: params, map: Profile.self, success: success, failure: failure)
    }
    
    func retrieveTermsOfUse(success: successClosure!, failure: failureClosure!) {
        self.getRequest("terms_of_service", params: nil, map: WebContent.self, success: success, failure: failure)
    }
    
    func retrievePrivacyPolicy(success: successClosure!, failure: failureClosure!) {
        self.getRequest("privacy_policy", params: nil, map: WebContent.self, success: success, failure: failure)
    }
}

private extension String {
    func byAddingHost() -> String {
        return ConfigHepler.baseHostUrl() + "/api/v1/" + self
    }
}

private extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        get {
            return self[self.startIndex.advancedBy(i)]
        }
    }
}