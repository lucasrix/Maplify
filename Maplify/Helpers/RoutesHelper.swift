//
//  RoutesHelper.swift
//  Maplify
//
//  Created by jowkame on 06.03.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension UIViewController {
    func routesOpenLoginViewController() {
        self.routesOpenViewController(Controllers.loginController)
    }
    
    func routesOpenTermsViewController() {
        self.routesOpenViewController(Controllers.termsController)

    }
    
    func routesOpenSignUpPhotoViewController() {
        self.routesOpenViewController(Controllers.signupPhotoController)
    }
    
    func routesOpenViewController(identifier: String) {
        let viewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(identifier)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func routesOpenSignUpViewController(photoImage: UIImage!, user: User) {
        let signupViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupController) as! SignupViewController
        signupViewController.photoImage = photoImage
        signupViewController.user = user
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    func routesOpenSignUpUpdateProfileViewController(user: User) {
        let signupUpdateProfileController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupUpdateProfileController) as! SignupUpdateProfileController
        signupUpdateProfileController.user = user
        self.navigationController?.pushViewController(signupUpdateProfileController, animated: true)
    }
}