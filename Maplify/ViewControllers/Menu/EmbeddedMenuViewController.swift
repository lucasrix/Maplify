//
//  EmbeddedMenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

public enum MenuItem: Int {
    case SectionAccount = 0
    case SectionNotifications
    case SectionEditProfile
    case SectionChangePassword
    case SectionInformation
    case SectionAbout
    case SectionPrivacyPolicy
    case SectionTermsOfService
    case SectionEmpty
    case SectionLogOut
    case SectionCopyright
}

class EmbeddedMenuViewController: UITableViewController {
    var delegate: MenuDelegate! = nil
    
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
            
        case MenuItem.SectionNotifications.rawValue:
            // TODO:
            // example
            // self.sendAction("routesOpenAudioStoryPointController")
            break
            
        case MenuItem.SectionEditProfile.rawValue:
            // TODO:
            break
            
        case MenuItem.SectionChangePassword.rawValue:
            // TODO:
            break
            
        case MenuItem.SectionAbout.rawValue:
            // TODO:
            break
            
        case MenuItem.SectionPrivacyPolicy.rawValue:
            // TODO:
            break
            
        case MenuItem.SectionTermsOfService.rawValue:
            // TODO:
            break
            
        case MenuItem.SectionLogOut.rawValue:
            self.logOutDidSelect()
            
        default:
            break
        }
    }
    
    func sendAction(actionString: String) {
        self.delegate?.menuDidSelectItem(actionString)
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logOutDidSelect() {
        // TODO:
    }
}

protocol MenuDelegate {
    func menuDidSelectItem(actionString:String)
}
