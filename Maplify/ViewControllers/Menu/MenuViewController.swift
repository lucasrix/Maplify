
//
//  MenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kProviderFacebook = "facebook"
let kAccountLabelHeight: CGFloat = 20
let kChangePasswordButtonHeight: CGFloat = 49
let kInformationLabelTopConstant: CGFloat = 28

class MenuViewController: ViewController {
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var informationlabel: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var ourStoryButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var accountLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var changePasswordButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var softwareVersionLabel: UILabel!
    @IBOutlet weak var changePasswordArrowImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
    }
    
    func setupViews() {
        self.setupAccountViews()
        self.setupInformationViews()
        self.setupLogoutViews()
    }
    
    func setupAccountViews() {
        let isProviderFacebook = SessionManager.currentUser().provider == kProviderFacebook
        self.accountLabel.text = isProviderFacebook == true ? String() : NSLocalizedString("Label.Account", comment: String()).uppercaseString
        self.accountLabelHeightConstraint.constant = isProviderFacebook == true ? 0 : kAccountLabelHeight
        let changePassButtonText = isProviderFacebook == true ? String() : NSLocalizedString("Button.ChangePassword", comment: String())
        self.changePasswordButton.setTitle(changePassButtonText, forState: .Normal)
        self.changePasswordButtonHeightConstraint.constant = isProviderFacebook == true ? 0 : kChangePasswordButtonHeight
        self.informationLabelTopConstraint.constant = isProviderFacebook == true ? 0 : kInformationLabelTopConstant
        self.changePasswordArrowImageView.hidden = isProviderFacebook
    }
    
    func setupInformationViews() {
        self.informationlabel.text = NSLocalizedString("Label.Information", comment: String()).uppercaseString
        self.ourStoryButton.setTitle(NSLocalizedString("Button.OurStory", comment: String()), forState: .Normal)
        self.privacyPolicyButton.setTitle(NSLocalizedString("Button.PrivacyPolicy", comment: String()), forState: .Normal)
        self.termsOfServiceButton.setTitle(NSLocalizedString("Button.TermsOfService", comment: String()), forState: .Normal)
    }
    
    func setupLogoutViews() {
        self.logoutButton.setTitle(NSLocalizedString("Button.LogOut", comment: String()), forState: .Normal)
        let appVersion = String().appVersion()
        let formattedString = NSLocalizedString("Label.SoftwareVersion", comment: String())
        self.softwareVersionLabel.text = String(format:formattedString, appVersion)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    @IBAction func cancelTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changeButtonTapped(sender: UIButton) {
        self.routesOpenChangePasswordViewController()
    }
    
    @IBAction func ourStoryTapped(sender: UIButton) {
        self.routesOpenOurStoryController()
    }
    
    @IBAction func privacyPolicyTapped(sender: UIButton) {
        self.routesOpenPolicyViewController()
    }
    
    @IBAction func termsOfUseTapped(sender: UIButton) {
        self.routesOpenTermsViewController()
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        self.signOut()
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
}
