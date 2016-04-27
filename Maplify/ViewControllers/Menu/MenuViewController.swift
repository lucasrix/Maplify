
//
//  MenuViewController.swift
//  Maplify
//
//  Created by - Jony - on 3/27/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class MenuViewController: ViewController {
    var delegate: MenuDelegate! = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextController = segue.destinationViewController as! EmbeddedMenuViewController
        nextController.delegate = self.delegate
    }
    
    // MARK: - actions
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
