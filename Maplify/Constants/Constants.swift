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
    static let stagingConfigFile = "config_staging"
    static let productionConfigFile = "config_production"
    static let localUserAccount = "localUserAccount"
    static let userAppLaunch = "userAppLaunch"
    static let locationEnabled = "locationEnabled"
    static let pushNotificationsEnabled = "pushNotificationsEnabled"
    static let userLocationLatitude = "userLocationLatitude"
    static let userLocationLongitude = "userLocationLongitude"
}

struct FileType {
    static let plist = "plist"
}

struct Network {
    static let isUserLogin = "isUserLogin"
    static let successStatusCodes = [200, 201]
    static let failureStatusCode500: Int = 500
    static let simpleAuthCancelCode = 100
    static let mapRequestTimeOut: NSTimeInterval = 10
    static let routingPrefix = "maplify:"
}

struct Controllers {
    static let loginController = "LoginController"
    static let signupPhotoController = "SignupPhotoController"
    static let signupController = "SignupController"
    static let signupUpdateProfileController = "SignupUpdateProfileController"
    static let termsController = "TermsController"
    static let policyController = "PolicyController"
    static let landingController = "LandingController"
    static let contentController = "ContentController"
    static let onboardController = "OnboardController"
    static let pageViewController = "PageViewController"
    static let onboardDiscoverController = "OnboardDiscoverController"
    static let onboardCaptureController = "OnboardCaptureController"
    static let storyPointCreationPopupController = "StoryPointCreationPopupController"
    static let captureController = "CaptureController"
    static let discoverController = "DiscoverController"
    static let storyPointEditDescriptionViewController = "StoryPointEditDescriptionViewController"
    static let storyPointEditInfoViewController = "StoryPointEditInfoViewController"
    static let storyPointAddAudioController = "StoryPointAddAudioController"
    static let menuViewController = "MenuViewController"
    static let storyPointAddPhotoVideoViewController = "StoryPointAddPhotoVideoViewController"
    static let addStoryViewController = "AddStoryViewController"
    static let recommendedSettingsController = "RecommendedSettingsController"
    static let storyPointEditController = "StoryPointEditController"
    static let storyDetailViewController = "StoryDetailViewController"
    static let storyPageViewController = "StoryPageViewController"
    static let storyDetailItemViewController = "StoryDetailItemViewController"
    static let profileController = "ProfileController"
    static let editProfileController = "EditProfileController"
    static let discoverChangeLocationPopupViewController = "DiscoverChangeLocationPopupViewController"
    static let storyEditController = "StoryEditController"
    static let storyAddPostsViewController = "StoryAddPostsViewController"
    static let storyCreateViewController = "StoryCreateViewController"
    static let shareStoryPointViewController = "ShareStoryPointViewController"
    static let shareStoryViewController = "ShareStoryViewController"
    static let resetPasswordViewController = "ResetPasswordController"
    static let changePasswordViewController = "ChangePasswordController"
}

struct AppIDs {
    static let facebookAppID = "1569818663334609"
}

struct Links {
    static let landingLink = "http://www.maplifyapp.com"
}

struct DefaultLocation {
    static let washingtonDC = (38.889931, -77.009003)
}

struct StaticMapSize {
    static let widthSmall = 200
    static let widthMedium = 400
    static let widthLarge = 600
}