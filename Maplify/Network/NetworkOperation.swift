//
//  NetworkOperation.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/6/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Alamofire

class NetworkOperation : ConcurrentOperation {
    var performRequestClosure: ((operation: NetworkOperation) -> ())!
    
    weak var request: Alamofire.Request?
    
    init(performRequestClosure: ((operation: NetworkOperation) -> ())!) {
        self.performRequestClosure = performRequestClosure
        super.init()
    }
    
    override func main() {
        self.performRequestClosure?(operation: self)
    }
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
}