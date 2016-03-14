//
//  AlertHelper.swift
//  table_classes
//
//  Created by Sergey on 2/23/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

typealias buttonClosure = (buttonIndex: Int) -> ()

extension UIViewController {
    
    func showAlert(title: String, message: String, cancel: String, buttons: [String], handle: buttonClosure) {
        self.showController(title, message: message, cancel: cancel, destructive: nil, buttons: buttons, style: .Alert, handle: handle)
    }
    
    func showMessageAlert(title: String!, message: String, cancel: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: cancel, style: .Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showActionSheet(title: String!, message: String, cancel: String, destructive: String!,
        buttons: [String], handle: buttonClosure) {
            self.showController(title, message: message, cancel: cancel, destructive: destructive, buttons: buttons, style: .ActionSheet, handle: handle)
    }
    
    private func showController(title: String!, message: String, cancel: String, destructive: String!,
        buttons: [String], style: UIAlertControllerStyle, handle: buttonClosure) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            for title in buttons {
                let alertAction = UIAlertAction(title: title, style: .Default,
                    handler: { (action: UIAlertAction) -> () in
                        let index = buttons.indexOf(action.title!)
                        handle(buttonIndex: index!)
                })
                alertController.addAction(alertAction)
            }
            
            if destructive?.length > 0 {
                let alertAction = UIAlertAction(title: destructive, style: .Destructive,
                    handler: { (action: UIAlertAction) -> () in
                        handle(buttonIndex: buttons.count)
                })
                alertController.addAction(alertAction)
            }
            
            if cancel.length > 0 {
                let alertAction = UIAlertAction(title: cancel, style: .Cancel,
                    handler: { (action: UIAlertAction) -> () in
                        let index = (style == .Alert || destructive == nil) ? buttons.count : buttons.count + 1
                        handle(buttonIndex: index)
                })
                alertController.addAction(alertAction)
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
    }
}


