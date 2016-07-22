//
//  RoutesHelper.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Photos
import Foundation

extension UIViewController {

    // MARK: - setup root controller
    func routesSetLandingController() {
        let landingViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.landingController)
        let navigationController = NavigationViewController(rootViewController: landingViewController)
        let window = ((UIApplication.sharedApplication().delegate?.window)!)! as UIWindow
        window.rootViewController = navigationController
    }
    
    func routesSetContentController() {
        let captureViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController)
        let navigationController = NavigationViewController(rootViewController: captureViewController)
        navigationController.navigationType = .Main
        let window = ((UIApplication.sharedApplication().delegate?.window)!)! as UIWindow
        window.rootViewController = navigationController
    }
    
    func routesSetLoginViewController() {
        let loginViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.loginController) as! LoginViewController
        loginViewController.backHidden = true
        let navigationController = NavigationViewController(rootViewController: loginViewController)
        let window = ((UIApplication.sharedApplication().delegate?.window)!)! as UIWindow
        window.rootViewController = navigationController
    }
    
    // MARK: - open controllers
    func routesOpenLoginViewController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.loginController)
    }
    
    func routesOpenTermsViewController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.termsController)
    }
    
    func routesOpenSignUpPhotoViewController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.signupPhotoController)
    }
    
    func routesOpenPolicyViewController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.policyController)
    }
    
    func routesOpenOurStoryController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.ourStoryController)
    }
    
    func routesOpenOnboardController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.onboardController)
    }

    func routesOpenRecommendedSettingsController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.recommendedSettingsController)
    }
    
    func routesOpenResetPasswordController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.resetPasswordViewController)
    }
    
    func routesOpenNotificationsController() {
        self.routesOpenViewController(UIStoryboard.mainStoryboard(), identifier: Controllers.notificationsController)
    }
    
    func routesOpenMenuController() {
        self.routesOpenViewController(UIStoryboard.menuStoryboard(), identifier: Controllers.menuViewController)
    }
    
    func routesOpenStoryCreateController(createStoryCompletion: createStoryClosure!) {
        let storyCreateController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyCreateViewController) as! StoryCreateViewController
        storyCreateController.createStoryCompletion = createStoryCompletion
        self.navigationController?.pushViewController(storyCreateController, animated: true)
    }
    
    func routesOpenStoryCreateCameraRollController(createStoryCompletion: createStoryClosure!) {
        let storyCreateCameraRollController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyCreateCameraRollController) as! StoryCreateCameraRollViewController
        storyCreateCameraRollController.createStoryCompletion = createStoryCompletion
        self.navigationController?.pushViewController(storyCreateCameraRollController, animated: true)
    }
    
    func routesOpenStoryCreateAddInfoController(selectedDrafts: [StoryPointDraft], createStoryCompletion: createStoryClosure!) {
        let storyCreateAddInfoController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyCreateAddInfoController) as! StoryCreateAddInfoViewController
        storyCreateAddInfoController.selectedDrafts = selectedDrafts
        storyCreateAddInfoController.createStoryCompletion = createStoryCompletion
        self.navigationController?.pushViewController(storyCreateAddInfoController, animated: true)
    }
    
    func routesOpenStoryCreateAddLocationController(searchLocationClosure: SearchLocationClosure!) {
        let storyCreateAddLocationController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyCreateAddLocationController) as! StoryCreateAddLocationViewController
        storyCreateAddLocationController.searchLocationClosure = searchLocationClosure
        self.navigationController?.pushViewController(storyCreateAddLocationController, animated: true)
    }
    
    func routesOpenDiscoverController(userProfileId: Int, supportUserProfile: Bool, stackSupport: Bool) {
        let discoverViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.discoverController) as! DiscoverViewController
        discoverViewController.userProfileId = userProfileId
        discoverViewController.supportUserProfile = supportUserProfile
        discoverViewController.stackSupport = stackSupport
        self.navigationController?.pushViewController(discoverViewController, animated: true)
    }
    
    func routesOpenEditProfileController(profileId: Int, photo: UIImage!, updateContentClosure: (() -> ())!) {
        let editProfileViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.editProfileController) as! EditProfileViewController
        editProfileViewController.profileId = profileId
        editProfileViewController.updateContentClosure = updateContentClosure
        self.navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    func routesOpenStoryPointEditController(storyPointId: Int, storyPointUpdateHandler: (() -> ())!) {
        let storyPointEditViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditController) as! StoryPointEditViewController
        storyPointEditViewController.storyPointId = storyPointId
        storyPointEditViewController.storyPointUpdateHandler = storyPointUpdateHandler
        self.navigationController?.pushViewController(storyPointEditViewController, animated: true)
    }
    
    func routesOpenStoryEditController(storyId: Int, editStoryCompletion: editStoryClosure!) {
        let editStoryController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.editStoryController) as! EditStoryViewController
        editStoryController.storyId = storyId
        editStoryController.editStoryCompletion = editStoryCompletion
        self.navigationController?.pushViewController(editStoryController, animated: true)
    }
    
    func routesOpenViewController(storyboard: UIStoryboard, identifier: String) {
        let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func routesOpenSignUpViewController(photoImage: UIImage!, user: User) {
        let signupViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupController) as! SignupViewController
        signupViewController.photoImage = photoImage
        signupViewController.user = user
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    func routesOpenSignUpUpdateProfileViewController(user: User) {
        let signupUpdateProfileController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupUpdateProfileController) as! SignupUpdateProfileController
        signupUpdateProfileController.user = user
        self.navigationController?.pushViewController(signupUpdateProfileController, animated: true)
    }
    
    func routesOpenStoryPointEditDescriptionController(storyPointKind: StoryPointKind, storyPointAttachmentId: Int, location: MCMapCoordinate!, selectedStoryIds: [Int]!, locationString: String, creationPostCompletion: creationPostClosure!) {
        let storyPointEditDescriptionController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditDescriptionViewController) as! StoryPointEditDescriptionViewController
        storyPointEditDescriptionController.storyPointKind = storyPointKind
        storyPointEditDescriptionController.location = location
        storyPointEditDescriptionController.locationString = locationString
        storyPointEditDescriptionController.storyPointAttachmentId = storyPointAttachmentId
        storyPointEditDescriptionController.selectedStoryIds = selectedStoryIds
        storyPointEditDescriptionController.creationPostCompletion = creationPostCompletion
        self.navigationController?.pushViewController(storyPointEditDescriptionController, animated: true)
    }
    
    func routesOpenStoryPointEditInfoController(storyPointDescription: String, storyPointKind: StoryPointKind, storyPointAttachmentId: Int, location: MCMapCoordinate) {
        let storyPointEditInfoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditInfoViewController) as! StoryPointEditInfoViewController
        storyPointEditInfoViewController.storyPointDescription = storyPointDescription
        storyPointEditInfoViewController.storyPointKind = storyPointKind
        storyPointEditInfoViewController.location = location
        storyPointEditInfoViewController.storyPointAttachmentId = storyPointAttachmentId
        self.navigationController?.pushViewController(storyPointEditInfoViewController, animated: true)
    }
    
    func routesOpenAudioStoryPointController(pickedLocation: MCMapCoordinate) {
        let storyPointAddAudioViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointAddAudioController) as! StoryPointAddAudioController
        storyPointAddAudioViewController.pickedLocation = pickedLocation
        self.navigationController?.pushViewController(storyPointAddAudioViewController, animated: true)
    }
    
    func routesOpenPhotoVideoViewController(pickedLocation: MCMapCoordinate, locationString: String, selectedStoryIds: [Int]!, creationPostCompletion: creationPostClosure!) {
        let storyPointAddPhotoVideoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointAddPhotoVideoViewController) as! StoryPointAddPhotoVideoViewController
        storyPointAddPhotoVideoViewController.pickedLocation = pickedLocation
        storyPointAddPhotoVideoViewController.locationString = locationString
        storyPointAddPhotoVideoViewController.selectedStoryIds = selectedStoryIds
        storyPointAddPhotoVideoViewController.creationPostCompletion = creationPostCompletion
        self.navigationController?.pushViewController(storyPointAddPhotoVideoViewController, animated: true)
    }

    func routesOpenAddToStoryController(selectedIds: [Int], storypointCreationSupport: Bool, pickedLocation: MCMapCoordinate!, locationString: String, updateStoryHandle: updateStoryClosure!, creationPostCompletion: creationPostClosure!) {
        let addStoryViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.addStoryViewController) as! AddStoryViewController
        addStoryViewController.updatedStoryIds = updateStoryHandle
        addStoryViewController.selectedIds = selectedIds
        addStoryViewController.storyPointCreationSupport = storypointCreationSupport
        addStoryViewController.pickedLocation = pickedLocation
        addStoryViewController.locationString = locationString
        addStoryViewController.creationPostCompletion = creationPostCompletion
        self.navigationController?.pushViewController(addStoryViewController, animated: true)
    }
    
    func routesOpenStoryAddPostsViewController(selectedStoryPoints: [StoryPoint]!, delegate: AddPostsDelegate?, storyModeCreation: Bool, storyName: String, storyDescription: String, createStoryCompletion: createStoryClosure!) {
        let storyAddPostsViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyAddPostsViewController) as! StoryAddPostsViewController
        storyAddPostsViewController.selectedStoryPoints = selectedStoryPoints
        storyAddPostsViewController.delegate = delegate
        storyAddPostsViewController.isStoryModeCreation = storyModeCreation
        storyAddPostsViewController.storyName = storyName
        storyAddPostsViewController.storyDescription = storyDescription
        storyAddPostsViewController.createStoryCompletion = createStoryCompletion
        self.navigationController?.pushViewController(storyAddPostsViewController, animated: true)
    }
    
    func routesOpenShareStoryPointViewController(storyPointId: Int, completion: (() -> ())!) {
        let shareStoryPointViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.shareStoryPointViewController) as! ShareStoryPointViewController
        shareStoryPointViewController.storyPointId = storyPointId
        shareStoryPointViewController.completion = completion
        self.navigationController?.pushViewController(shareStoryPointViewController, animated: true)
    }
    
    func routesOpenShareStoryViewController(storyId: Int, completion: (() -> ())!) {
        let shareStoryViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.shareStoryViewController) as! ShareStoryViewController
        shareStoryViewController.storyId = storyId
        shareStoryViewController.completion = completion
        self.navigationController?.pushViewController(shareStoryViewController, animated: true)
    }
    
    func routesOpenSignupGetCityViewController(user: User) {
        let signupGetCityViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupGetCityController) as! SignupGetCityViewController
        signupGetCityViewController.user = user
        self.navigationController?.pushViewController(signupGetCityViewController, animated: true)
    }
    
    // MARK: - push from left
    func routesPushFromLeftStoryPointCaptureViewController(storyPointId: Int) {
        let captureViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController) as! CaptureViewController
        captureViewController.contentType = .StoryPoint
        captureViewController.selectedStoryPointId = storyPointId
        captureViewController.poppingControllerSupport = true
        self.routesPushFromLeftViewController(captureViewController)
    }
    
    func routesPushFromLeftStoryCaptureViewController(storyId: Int) {
        let captureViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController) as! CaptureViewController
        captureViewController.contentType = .Story
        captureViewController.selectedStoryId = storyId
        captureViewController.poppingControllerSupport = true
        self.routesPushFromLeftViewController(captureViewController)
    }
    
    func routesPushFromLeftViewController(controller: ViewController) {
        let transition = CATransition()
        transition.duration = AnimationDurations.pushControllerDefault
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transition.timingFunction = timingFunction
        self.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func routesOpenSharedContentController(sharedType: String, sharedId: Int) {
        let captureViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController) as! CaptureViewController
        if sharedType == SharingKeys.typeStoryPoint {
            captureViewController.contentType = .StoryPoint
            captureViewController.selectedStoryPointId = sharedId
        } else if sharedType == SharingKeys.typeStory {
            captureViewController.contentType = .Story
            captureViewController.selectedStoryId = sharedId
        }
        let navigationController = NavigationViewController(rootViewController: captureViewController)
        let window = ((UIApplication.sharedApplication().delegate?.window)!)! as UIWindow
        window.rootViewController = navigationController
    }

    func routesOpenChangePasswordViewController() {
        let changePasswordViewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.changePasswordViewController) as! ChangePasswordViewController
        self.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
    
    func routesOpenFollowingContentController(showingListOption: ShowingListOption) {
        let contentFollowingViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.contentFollowingViewController) as! ContentFollowingViewController
        contentFollowingViewController.showingListOption = showingListOption
        self.navigationController?.pushViewController(contentFollowingViewController, animated: true)
    }
    
    func routesOpenReportsController(postId: Int, postType: PostType, completionClosure: (() -> ())!) {
        let reportsViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.reportsController) as! ReportsViewController
        reportsViewController.postId = postId
        reportsViewController.postType = postType
        reportsViewController.completionClosure = completionClosure
        self.navigationController?.pushViewController(reportsViewController, animated: true)
    }
    
    func routesOpenReportSucceddController(completionClosure: (() -> ())!) {
        let reportSuccessController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.reportSuccessController) as! ReportSuccessViewController
        reportSuccessController.completionClosure = completionClosure
        self.navigationController?.pushViewController(reportSuccessController, animated: true)
    }
    
    // MARK: - open as popup controllers
    func routesShowPopupStoryPointCreationController(delegate: StoryPointCreationPopupDelegate, location: MCMapCoordinate) {
        let storyPointCreationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointCreationPopupController) as! StoryPointCreationPopupViewController
        storyPointCreationPopupController.delegate = delegate
        storyPointCreationPopupController.location = location
        storyPointCreationPopupController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(storyPointCreationPopupController, animated: true, completion: nil)
    }
    
    func routerShowDiscoverChangeLocationPopupController(delegate: DiscoverChangeLocationDelegate) {
        let discoverChangeLocationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.discoverChangeLocationPopupViewController) as! DiscoverChangeLocationPopupViewController
        discoverChangeLocationPopupController.delegate = delegate
        let nav = NavigationViewController(rootViewController: discoverChangeLocationPopupController)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
}