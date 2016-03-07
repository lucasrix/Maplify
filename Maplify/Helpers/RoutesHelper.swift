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
        let loginViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.loginControllerId)
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func routesOpenSignUpPhotoViewController() {
         let signupPhotoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupPhotoController)
        self.navigationController?.pushViewController(signupPhotoViewController, animated: true)
    }
    
    func routesOpenSignUpViewController(photoImage: UIImage!, account: Account) {
        let signupViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.signupController) as! SignupViewController
        signupViewController.photoImage = photoImage
        signupViewController.account = account
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
}