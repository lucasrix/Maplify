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
    @IBOutlet weak var tableView: UITableView!
    
    var notificationsDataSource: CSBaseTableDataSource! = nil
    var notificationsActiveModel = CSActiveModel()
    
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
        self.setupDataSource()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = NSLocalizedString("Controller.Notifications", comment: String())
    }
    
    func setupDataSource() {
        self.notificationsDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.notificationsActiveModel, delegate: self)
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
        self.notificationsActiveModel.removeData()
        
        let realm = try! Realm()
        let notifications = Array(realm.objects(Notification))
        
        self.notificationsActiveModel.addItems(notifications, cellIdentifier: String(NotificationsTableViewCell), sectionTitle: nil, delegate: self)
        self.notificationsDataSource.reloadTable()
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.retrieveNotifications({ [weak self] (response) in
            NotificationsManager.saveNotificationItems(response as! [String: AnyObject])
            
            self?.loadItemsFromDB()
            
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
