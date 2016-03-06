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
        let loginViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.kLoginControllerId)
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func routesOpenSignUpPhotoViewController() {
         let signupPhotoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.kSignupPhotoController)
        self.navigationController?.pushViewController(signupPhotoViewController, animated: true)
    }
}