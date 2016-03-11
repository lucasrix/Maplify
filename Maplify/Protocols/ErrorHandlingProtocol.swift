//
//  ErrorHandlingProtocol.swift
//  Maplify
//
//  Created by Sergey on 3/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

protocol ErrorHandlingProtocol {
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!)
}