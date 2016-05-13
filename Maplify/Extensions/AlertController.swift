//
//  AlertHelper.swift
//  table_classes
//
//  Created by Sergey on 2/23/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

enum ActionSheetButtonIndexes: Int {
    case Destructive = 0
}

let kAttributedMessageDefaultFontSize: CGFloat = 13

let kAttributedMessageKey = "attributedMessage"

typealias buttonClosure = (buttonIndex: Int) -> ()

extension UIViewController {
    
    func showAlert(title: String!, message: String, cancel: String!, buttons: [String]!, handle: buttonClosure) {
        self.showController(title, message: message, cancel: cancel, destructive: nil, buttons: buttons, style: .Alert, handle: handle)
    }
    
    func showMessageAlert(title: String!, message: String, cancel: String) {
       self.showMessageAlert(title, message: message, cancel: cancel, handle: nil)
    }
    
    func showMessageAlert(title: String!, message: String, cancel: String, handle: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: cancel, style: .Default, handler: handle)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showInputMessageAlert(title: String!, message: String, ok: String, cancel: String, handle: ((UIAlertAction, UIAlertController) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let alertAction = UIAlertAction(title: ok, style: .Default) { (alertAction) in
            handle?(alertAction, alertController)
        }
        alertController.addAction(alertAction)

        let cancelAction = UIAlertAction(title: cancel, style: .Cancel)  { (alertAction) in
            handle?(alertAction, alertController)
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showActionSheet(title: String!, message: String!, cancel: String, destructive: String!,
        buttons: [String], handle: buttonClosure) {
            self.showController(title, message: message, cancel: cancel, destructive: destructive, buttons: buttons, style: .ActionSheet, handle: handle)
    }
    
    func showActionSheet(attributedMessage: NSMutableAttributedString!, cancel: String, destructive: String!,
                         buttons: [String], handle: buttonClosure) {
        self.showController(nil, message: nil, attributedMessage: attributedMessage, cancel: cancel, destructive: destructive, buttons: buttons, style: .ActionSheet, handle: handle)
    }
    
    private func showController(title: String!, message: String!, cancel: String!, destructive: String!,
        buttons: [String]!, style: UIAlertControllerStyle, handle: buttonClosure) {
        self.showController(title, message: message, attributedMessage: nil, cancel: cancel, destructive: destructive, buttons: buttons, style: style, handle: handle)
    }
    
    private func showController(title: String!, message: String!, attributedMessage: NSMutableAttributedString!, cancel: String!, destructive: String!,
                                buttons: [String]!, style: UIAlertControllerStyle, handle: buttonClosure) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if buttons != nil {
            for title in buttons {
                let alertAction = UIAlertAction(title: title, style: .Default,
                                                handler: { (action: UIAlertAction) -> () in
                                                    let index = buttons.indexOf(action.title!)
                                                    handle(buttonIndex: index!)
                })
                alertController.addAction(alertAction)
            }
        }
        
        if destructive?.length > 0 {
            let alertAction = UIAlertAction(title: destructive, style: .Destructive,
                                            handler: { (action: UIAlertAction) -> () in
                                                handle(buttonIndex: buttons.count)
            })
            alertController.addAction(alertAction)
        }
        
        if cancel?.length > 0 {
            let alertAction = UIAlertAction(title: cancel, style: .Cancel,
                                            handler: { (action: UIAlertAction) -> () in
                                                let buttonsCount = (buttons != nil) ? buttons.count : 0
                                                let index = (style == .Alert || destructive == nil) ? buttonsCount : buttonsCount + 1
                                                handle(buttonIndex: index)
            })
            alertController.addAction(alertAction)
        }
        
        if attributedMessage?.string.length > 0 {
            alertController.setValue(attributedMessage, forKey: kAttributedMessageKey)
        }
     
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}


