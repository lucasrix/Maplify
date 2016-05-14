//
//  FollowingAlertController.swift
//  Maplify
//
//  Created by - Jony - on 5/15/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kAttributedMessageDefaultFontSize: CGFloat = 13

extension ViewController {
    func askForUnfollow(userId: Int, completionClosure: ((selectedButtonIndex: Int) -> ())) {
        let user = SessionManager.findUser(userId)
        let username = user.profile.firstName + " " + user.profile.lastName
        let message = NSLocalizedString("Button.Unfollow", comment: String()) + " " + username + "?"
        
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.warmGrey(), range: NSMakeRange(0, NSString(string: attributedMessage.string).length))
        let colorRange = (message as NSString).rangeOfString(username)
        attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGreyBlue(), range: colorRange)
        attributedMessage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(kAttributedMessageDefaultFontSize), range: NSMakeRange(0, NSString(string: attributedMessage.string).length))
        attributedMessage.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(kAttributedMessageDefaultFontSize), range: colorRange)
        
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let destructive = NSLocalizedString("Button.Unfollow", comment: String())
        
        self.showActionSheet(attributedMessage, cancel: cancel, destructive: destructive, buttons: []) { (buttonIndex) in
            completionClosure(selectedButtonIndex: buttonIndex)
        }
    }
}
