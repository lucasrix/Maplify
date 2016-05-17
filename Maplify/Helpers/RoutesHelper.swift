//
//  RoutesHelper.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

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
        let contentViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.contentController)
        let navigationController = NavigationViewController(rootViewController: contentViewController)
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
    
    func routesOpenOnboardController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.onboardController)
    }

    func routesOpenRecommendedSettingsController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.recommendedSettingsController)
    }
    
    func routesOpenResetPasswordController() {
        self.routesOpenViewController(UIStoryboard.authStoryboard(), identifier: Controllers.resetPasswordViewController)
    }
    
    func routesOpenStoryCreateController(createStoryClosure: (() -> ())!) {
        let storyCreateController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyCreateViewController) as! StoryCreateViewController
        storyCreateController.createStoryClosure = createStoryClosure
        self.navigationController?.pushViewController(storyCreateController, animated: true)
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
    
    func routesOpenStoryPointEditController(storyPointId: Int, storyPointUpdateHandler: () -> ()) {
        let storyPointEditViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditController) as! StoryPointEditViewController
        storyPointEditViewController.storyPointId = storyPointId
        storyPointEditViewController.storyPointUpdateHandler = storyPointUpdateHandler
        self.navigationController?.pushViewController(storyPointEditViewController, animated: true)
    }
    
    func routesOpenStoryEditController(storyId: Int, storyUpdateHandler: () -> ()) {
        let storyEditViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyEditController) as! StoryEditViewController
        storyEditViewController.storyId = storyId
        storyEditViewController.storyUpdateHandler = storyUpdateHandler
        self.navigationController?.pushViewController(storyEditViewController, animated: true)
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
    
    func routesOpenStoryPointEditDescriptionController(storyPointKind: StoryPointKind, storyPointAttachmentId: Int, location: MCMapCoordinate) {
        let storyPointEditDescriptionController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditDescriptionViewController) as! StoryPointEditDescriptionViewController
        storyPointEditDescriptionController.storyPointKind = storyPointKind
        storyPointEditDescriptionController.location = location
        storyPointEditDescriptionController.storyPointAttachmentId = storyPointAttachmentId
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
    
    func routesOpenPhotoVideoViewController(pickedLocation: MCMapCoordinate) {
        let storyPointAddPhotoVideoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointAddPhotoVideoViewController) as! StoryPointAddPhotoVideoViewController
        storyPointAddPhotoVideoViewController.pickedLocation = pickedLocation
        self.navigationController?.pushViewController(storyPointAddPhotoVideoViewController, animated: true)
    }

    func routesOpenAddToStoryController(selectedIds: [Int], updateStoryHandle: updateStoryClosure) {
        let addStoryViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.addStoryViewController) as! AddStoryViewController
        addStoryViewController.updatedStoryIds = updateStoryHandle
        addStoryViewController.selectedIds = selectedIds
        self.navigationController?.pushViewController(addStoryViewController, animated: true)
    }
    
    func routesOpenStoryDetailViewController(storyPoints: [StoryPoint], selectedIndex: Int, storyTitle: String, stackSupport: Bool) {
        let storyDetailViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyDetailViewController) as! StoryDetailViewController
        storyDetailViewController.storyPoints = storyPoints
        storyDetailViewController.selectedIndex = selectedIndex
        storyDetailViewController.storyTitle = storyTitle
        storyDetailViewController.stackSupport = stackSupport
        self.navigationController?.pushViewController(storyDetailViewController, animated: true)
    }
    
    func routesOpenStoryAddPostsViewController(selectedStoryPoints: [StoryPoint]!, delegate: AddPostsDelegate?, storyModeCreation: Bool, storyName: String, storyDescription: String, storyCreateClosure: (() -> ())!) {
        let storyAddPostsViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyAddPostsViewController) as! StoryAddPostsViewController
        storyAddPostsViewController.selectedStoryPoints = selectedStoryPoints
        storyAddPostsViewController.delegate = delegate
        storyAddPostsViewController.isStoryModeCreation = storyModeCreation
        storyAddPostsViewController.storyName = storyName
        storyAddPostsViewController.storyDescription = storyDescription
        storyAddPostsViewController.createStoryClosure = storyCreateClosure
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
    func routesPushFromLeftCaptureViewController(story: Story!) {
        let captureViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.captureController) as! CaptureViewController
        captureViewController.publicStoryPointsSupport = true
        captureViewController.publicStory = story
        
        let transition = CATransition()
        transition.duration = AnimationDurations.pushControllerDefault
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        transition.timingFunction = timingFunction
        self.navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(captureViewController, animated: false)
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
    
    // MARK: - open as popup controllers
    func routesShowPopupStoryPointCreationController(delegate: StoryPointCreationPopupDelegate, location: MCMapCoordinate) {
        let storyPointCreationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointCreationPopupController) as! StoryPointCreationPopupViewController
        storyPointCreationPopupController.delegate = delegate
        storyPointCreationPopupController.location = location
        storyPointCreationPopupController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(storyPointCreationPopupController, animated: true, completion: nil)
    }
    
    func routerShowMenuController(delegate: MenuDelegate) {
        let menuController = UIStoryboard.menuStoryboard().instantiateViewControllerWithIdentifier(Controllers.menuViewController) as! MenuViewController
        menuController.delegate = delegate
        self.navigationController?.presentViewController(menuController, animated: true, completion: nil)
    }
    
    func routerShowDiscoverChangeLocationPopupController(delegate: DiscoverChangeLocationDelegate) {
        let discoverChangeLocationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.discoverChangeLocationPopupViewController) as! DiscoverChangeLocationPopupViewController
        discoverChangeLocationPopupController.delegate = delegate
        let nav = NavigationViewController(rootViewController: discoverChangeLocationPopupController)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
}