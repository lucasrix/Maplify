//
//  Constants.swift
//  Maplify
//
//  Created by Sergey on 2/26/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

// MARK: - Base constants
struct Config {
    static let production = "PRODUCTION"
    static let configFile = "config"
    static let localUserAccount = "localUserAccount"
    static let userAppLaunch = "userAppLaunch"
}

struct FileType {
    static let plist = "plist"
}

struct URL {
    static let stagingHost = "http://maplify.herokuapp.com"
    static let productionHost = "http://maplify.herokuapp.com"
}

struct Network {
    static let successStatusCodes = [200, 201]
}

struct Controllers {
    static let loginControllerId = "LoginController"
    static let signupPhotoController = "SignupPhotoController"
    static let signupController = "SignupController"
}