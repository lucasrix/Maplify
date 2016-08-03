//
//  LandingViewController.swift
//  Maplify
//
//  Created by Sergey on 3/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import TTTAttributedLabel

let kLoginActiveLink = "login"
let kTermsActiveLink = "terms"
let kPolicyActiveLink = "policy"

let kFacebookButtonImageInset: CGFloat = 20
let kEmailButtonImageInset: CGFloat = 68
let kLabelFontSize: CGFloat = 15
let kLoginButtonsFontSize: CGFloat = 18

class LandingViewController: ViewController, TTTAttributedLabelDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var emailButton: RoundedButton!
    @IBOutlet weak var facebookButton: RoundedButton!
    @IBOutlet weak var loginLabel: TTTAttributedLabel!
    @IBOutlet weak var termsLabel: TTTAttributedLabel!
   
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupButtons()
        self.setupLabels()
    }
    
    func setupButtons() {
        self.facebookButton.setup(UIColor.windowsBlue(), selectedColor: UIColor.cornflowerBlue(), font: UIFont.systemFontOfSize(kLoginButtonsFontSize))
        self.facebookButton.setTitle(NSLocalizedString("Button.FacebookLogin", comment: String()), forState: .Normal)
        
        self.emailButton.setup(UIColor.inactiveWhite(), selectedColor: UIColor.activeWhite(), font: UIFont.systemFontOfSize(kLoginButtonsFontSize))
        self.emailButton.setTitle(NSLocalizedString("Button.EmailSignup", comment: String()), forState: .Normal)
        
        if ConfigHepler.screenSmallerThanIPhoneSixSize() {
            self.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kFacebookButtonImageInset)
            self.emailButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEmailButtonImageInset)
        }
    }
    
    func setupLabels() {
        self.setupLoginLabel()
        self.setupTermsLabel()
    }
    
    func setupLoginLabel() {
        let loginStr = NSLocalizedString("Controller.Landing.Login", comment: String())
        let loginRangeStr = NSLocalizedString("Controller.Landing.RangeLogin", comment: String())
        let font = UIFont.systemFontOfSize(kLabelFontSize)
        self.loginLabel.setupDefaultAttributes(loginStr, textColor: UIColor.warmGrey(), font: font, delegate: self)
        self.loginLabel.setupLinkAttributes(UIColor.whiteColor(), underlined: false)
        self.loginLabel.addURLLink(kLoginActiveLink, str: loginStr, rangeStr: loginRangeStr)
    }
    
    func setupTermsLabel() {
        let termsStr = NSLocalizedString("Controller.Landing.Terms", comment: String())
        let termsRangeStr = NSLocalizedString("Controller.Landing.RangeTerms", comment: String())
        let policyRangeStr = NSLocalizedString("Controller.Landing.RangePolicy", comment: String())
        let font = UIFont.systemFontOfSize(kLabelFontSize)
        self.termsLabel.setupDefaultAttributes(termsStr, textColor: UIColor.warmGrey(), font: font, delegate: self)
        self.termsLabel.setupLinkAttributes(UIColor.whiteColor(), underlined: false)
        self.termsLabel.addURLLink(kTermsActiveLink, str: termsStr, rangeStr: termsRangeStr)
        self.termsLabel.addURLLink(kPolicyActiveLink, str: termsStr, rangeStr: policyRangeStr)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    @IBAction func facebookButtonDidTap(sender: AnyObject) {
        FacebookHelper.facebookAuthorize(self, success: { [weak self] (token) in
            ApiClient.sharedClient.facebookAuth(token,
                success: { (response) -> () in
                    let user = response as! User
                    
                    if user.profile.city.length > 0 {
                        SessionManager.saveCurrentUser(user)
                        SessionHelper.sharedHelper.userLogin(true)
                        self?.routesSetContentController()
                    } else {
                        self?.routesOpenSignupGetCityViewController(user)
                    }
                },
                failure: { (statusCode, errors, localDescription, messages) -> () in
                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                }
            )
            }) { [weak self] (error) in
                if error != nil {
                     self?.showMessageAlert(NSLocalizedString("Alert.Error", comment: String()), message: error.description, cancel: NSLocalizedString("Button.Ok", comment: String()))
                }
        }
    }

    @IBAction func emailButtonDidTap(sender: AnyObject) {
        self.routesOpenSignUpPhotoViewController()
    }
    
    // MARK: - TTTAttributedLabelDelegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.absoluteString == kLoginActiveLink {
            self.routesOpenLoginViewController()
        } else if url.absoluteString == kTermsActiveLink {
            self.routesOpenTermsViewController()
        } else if url.absoluteString == kPolicyActiveLink {
            self.routesOpenPolicyViewController()
        }
    }
    
    //MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
