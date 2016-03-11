//
//  LandingViewController.swift
//  Maplify
//
//  Created by Sergey on 3/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SimpleAuth

let kLoginActiveLink = "login"
let kTermsActiveLink = "terms"
let kPolicyActiveLink = "policy"

let kFacebookButtonImageInset: CGFloat = 20
let kEmailButtonImageInset: CGFloat = 68
let kLabelFontSize: CGFloat = 15
let kLoginButtonsFontSize: CGFloat = 18

class LandingViewController: ViewController, TTTAttributedLabelDelegate {
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
        self.loginLabel.setupLinkAttributes(UIColor.whiteColor())
        self.loginLabel.addURLLink(kLoginActiveLink, str: loginStr, rangeStr: loginRangeStr)
    }
    
    func setupTermsLabel() {
        let termsStr = NSLocalizedString("Controller.Landing.Terms", comment: String())
        let termsRangeStr = NSLocalizedString("Controller.Landing.RangeTerms", comment: String())
        let policyRangeStr = NSLocalizedString("Controller.Landing.RangePolicy", comment: String())
        let font = UIFont.systemFontOfSize(kLabelFontSize)
        self.termsLabel.setupDefaultAttributes(termsStr, textColor: UIColor.warmGrey(), font: font, delegate: self)
        self.termsLabel.setupLinkAttributes(UIColor.whiteColor())
        self.termsLabel.addURLLink(kTermsActiveLink, str: termsStr, rangeStr: termsRangeStr)
        self.termsLabel.addURLLink(kPolicyActiveLink, str: termsStr, rangeStr: policyRangeStr)
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    @IBAction func facebookButtonDidTap(sender: AnyObject) {
        SimpleAuth.facebookAuthorize { [weak self] (response, error) -> () in
            if (error != nil) {
                self?.showMessageAlert(NSLocalizedString("Alert.Error", comment: String()), message: error.description, cancel: NSLocalizedString("Button.Ok", comment: String()))
            } else {
                self?.showProgressHUD()

                let credentials = (response as! [String: AnyObject])["credentials"]
                let token = (credentials as! [String: AnyObject])["token"] as! String
                
                ApiClient.sharedClient.facebookAuth(token,
                    success: { (response) -> () in
                        self?.hideProgressHUD()
                        self?.routesOpenSignUpUpdateProfileViewController(response as! User)
                    },
                    failure: { (statusCode, errors, localDescription, messages) -> () in
                        self?.hideProgressHUD()
                        print(errors)
                    }
                )

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
    // TODO:
        } else if url.absoluteString == kPolicyActiveLink {
    // TODO:
        }
    }
}
