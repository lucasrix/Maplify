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
    
    func routesOpenProfileController(profileId: Int) {
        let profileViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.profileController) as! ProfileViewController
        profileViewController.profileId = profileId
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func routesOpenEditProfileController(profileId: Int, photo: UIImage!) {
        let editProfileViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.editProfileController) as! EditProfileViewController
        editProfileViewController.profileId = profileId
        editProfileViewController.updatedImage = photo
        self.navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    func routesOpenStoryPointEditController(storyPointId: Int, storyPointUpdateHandler: () -> ()) {
        let storyPointEditViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditController) as! StoryPointEditViewController
        storyPointEditViewController.storyPointId = storyPointId
        storyPointEditViewController.storyPointUpdateHandler = storyPointUpdateHandler
        self.navigationController?.pushViewController(storyPointEditViewController, animated: true)
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
    
    func routesOpenStoryPointEditDescriptionController(storyPointKind: StoryPointKind, storyPointAttachmentId: String, location: MCMapCoordinate) {
        let storyPointEditDescriptionController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditDescriptionViewController) as! StoryPointEditDescriptionViewController
        storyPointEditDescriptionController.storyPointKind = storyPointKind
        storyPointEditDescriptionController.location = location
        storyPointEditDescriptionController.storyPointAttachmentId = storyPointAttachmentId
        self.navigationController?.pushViewController(storyPointEditDescriptionController, animated: true)
    }
    
    func routesOpenStoryPointEditInfoController(storyPointDescription: String, storyPointKind: StoryPointKind, storyPointAttachmentId: String, location: MCMapCoordinate) {
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

    func routesOpenAddToStoryController(updateStoryHandle: updateStoryClosure) {
        let addStoryViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.addStoryViewController) as! AddStoryViewController
        addStoryViewController.updatedStoryIds = updateStoryHandle
        self.navigationController?.pushViewController(addStoryViewController, animated: true)
    }
    
    func routesOpenStoryDetailViewController(storyPoints: [StoryPoint], selectedIndex: Int, storyTitle: String) {
        let storyDetailViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyDetailViewController) as! StoryDetailViewController
        storyDetailViewController.storyPoints = storyPoints
        storyDetailViewController.selectedIndex = selectedIndex
        storyDetailViewController.storyTitle = storyTitle
        self.navigationController?.pushViewController(storyDetailViewController, animated: true)
    }
    
    // MARK: - open as popup controllers
    func routesShowPopupStoryPointCreationController(delegate: StoryPointCreationPopupDelegate, location: MCMapCoordinate) {
        let storyPointCreationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointCreationPopupController) as! StoryPointCreationPopupViewController
        storyPointCreationPopupController.delegate = delegate
        storyPointCreationPopupController.location = location
        storyPointCreationPopupController.modalPresentationStyle = .OverCurrentContext
        self.navigationController?.presentViewController(storyPointCreationPopupController, animated: true, completion: nil)
    }
    
    func routerShowMenuController(delegate: MenuDelegate) {
        let menuController = UIStoryboard.menuStoryboard().instantiateViewControllerWithIdentifier(Controllers.menuViewController) as! MenuViewController
        menuController.delegate = delegate
        self.navigationController?.presentViewController(menuController, animated: true, completion: nil)
    }
}