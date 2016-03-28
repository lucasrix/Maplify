//
//  ModelManager.swift
//  Maplify
//
//  Created by Sergey on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

protocol ModelManagerProtocol {
    func manageResponse(response: [String : AnyObject]) -> AnyObject!
}

class ModelManager: ModelManagerProtocol {
    
    // MARK: - methods to override
    func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        return nil
    }
}