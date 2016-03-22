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
        self.routesOpenViewController(Controllers.loginController)
    }
    
    func routesOpenTermsViewController() {
        self.routesOpenViewController(Controllers.termsController)
    }
    
    func routesOpenSignUpPhotoViewController() {
        self.routesOpenViewController(Controllers.signupPhotoController)
    }
    
    func routesOpenPolicyViewController() {
        self.routesOpenViewController(Controllers.policyController)
    }
    
    func routesOpenOnboardController() {
        self.routesOpenViewController(Controllers.onboardController)
    }
    
    func routesOpenViewController(identifier: String) {
        let viewController = UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(identifier)
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
    
    func routesOpenStoryPointEditDescriptionController(storyPointKind: StoryPointKind) {
        let storyPointEditDescriptionController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditDescriptionViewController) as! StoryPointEditDescriptionViewController
        storyPointEditDescriptionController.type = storyPointKind
        self.navigationController?.pushViewController(storyPointEditDescriptionController, animated: true)
    }
    
    func routesOpenStoryPointEditInfoController(storyPointDescription: String, storyPointKind: StoryPointKind) {
        let storyPointEditInfoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointEditInfoViewController) as! StoryPointEditInfoViewController
        storyPointEditInfoViewController.storyPointDescription = storyPointDescription
        storyPointEditInfoViewController.storyPointKind = storyPointKind
        self.navigationController?.pushViewController(storyPointEditInfoViewController, animated: true)
    }
    
    // MARK: - open as popup controllers
    func routesShowPopupStoryPointCreationController(delegate: StoryPointCreationPopupDelegate) {
        let storyPointCreationPopupController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPointCreationPopupController) as! StoryPointCreationPopupViewController
        storyPointCreationPopupController.delegate = delegate
        storyPointCreationPopupController.modalPresentationStyle = .OverCurrentContext
        self.navigationController?.presentViewController(storyPointCreationPopupController, animated: true, completion: nil)
    }
}