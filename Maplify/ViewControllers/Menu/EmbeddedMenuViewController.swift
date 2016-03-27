//
//  EmbeddedMenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

public enum MenuItem: Int {
    case Notifications = 1
    case EditProfile = 2
    case ChangePassword = 3
    case About = 5
    case PrivacyPolicy = 6
    case TermsOfService = 7
    case LogOut = 9
}

class EmbeddedMenuViewController: UITableViewController {
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.tableView.separatorColor = UIColor.darkGreyBlue()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectMenuItem(indexPath.row)
    }
    
    // MARK: - private
    func didSelectMenuItem(index: Int) {
        switch index {
            
        case MenuItem.Notifications.rawValue:
            self.notificationsDidSelect()
            
        case MenuItem.EditProfile.rawValue:
            self.editProfileDidSelect()
            
        case MenuItem.ChangePassword.rawValue:
            self.changePasswordDidSelect()
            
        case MenuItem.About.rawValue:
            self.aboutDidSelect()
            
        case MenuItem.PrivacyPolicy.rawValue:
            self.privacyPolicyDidSelect()
            
        case MenuItem.TermsOfService.rawValue:
            self.termsOfServiceDidSelect()
            
        case MenuItem.LogOut.rawValue:
            self.logOutDidSelect()
            
        default:
            break
        }
    }
    
    func notificationsDidSelect() {
        // TODO:
    }
    
    func editProfileDidSelect() {
        // TODO:
    }
    
    func changePasswordDidSelect() {
        // TODO:
    }
    
    func aboutDidSelect() {
        // TODO:
    }
    
    func privacyPolicyDidSelect() {
        // TODO:
    }
    
    func termsOfServiceDidSelect() {
        // TODO:
    }
    
    func logOutDidSelect() {
        // TODO:
    }
}
