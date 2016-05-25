
//
//  MenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class MenuViewController: ViewController, MenuDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextController = segue.destinationViewController as! EmbeddedMenuViewController
        nextController.delegate = self
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    @IBAction func cancelTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - MenuDelegate
    func menuDidSelectItem(actionString:String) {
        self.performSelector(Selector(actionString))
    }
    
    func signOut() {
        SessionHelper.sharedHelper.removeSessionData()
        SessionHelper.sharedHelper.removeSessionAuthCookies()
        SessionHelper.sharedHelper.removeDatabaseData()
        
        self.showProgressHUD()
        ApiClient.sharedClient.signOut({ [weak self] (response) in
            self?.hideProgressHUD()
            RootViewController.navigationController().routesSetLandingController()
            },
                                       failure:  { [weak self] (statusCode, errors, localDescription, messages) in
                                        self?.hideProgressHUD()
                                        RootViewController.navigationController().routesSetLandingController()
            }
        )
    }
    
    func changePassword() {
        self.routesOpenChangePasswordViewController()
    }
    
    func policy() {
        self.routesOpenPolicyViewController()
    }
    
    func terms() {
        self.routesOpenTermsViewController()
    }
    
    func ourStory() {
        self.routesOpenOurStoryController()
    }
}
