//
//  NotificationsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

class NotificationsViewController: ViewController {
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
        self.loadRemoteData()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = NSLocalizedString("Controller.Notifications", comment: String())
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    override func backTapped() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.backTapped()
    }
    
    func loadItemsFromDB() {
        let realm = try! Realm()
        let notifications = Array(realm.objects(Notification))
        print(notifications)
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.retrieveNotifications({ (response) in
            NotificationsManager.saveNotificationItems(response as! [String: AnyObject])
            
            }) { (statusCode, errors, localDescription, messages) in
                //
        }
    }
}
