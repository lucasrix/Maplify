//
//  NotificationsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/16/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import INSPullToRefresh.UIScrollView_INSPullToRefresh
import UIKit

class NotificationsViewController: ViewController, NotificationsCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var notificationsDataSource: CSBaseTableDataSource! = nil
    var notificationsActiveModel = CSActiveModel()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadRemoteData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadItemsFromDB()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.ins_removePullToRefresh()
        }
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupPlaceholder()
        self.setupDataSource()
        self.setupPullToRefresh()
    }
    
    func setupPlaceholder() {
        self.placeholderLabel.text = NSLocalizedString("Text.Placeholder.Notifications", comment: String())
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
    
    func loadItemsFromDB() {
        self.notificationsActiveModel.removeData()
        
        let realm = try! Realm()
        let notifications = Array(realm.objects(Notification).filter("action_user != nil AND (notificable_user != nil OR notificable_storypoint != nil OR (notificable_story != nil AND notificable_story.storyPoints.@count > 0))").sorted("created_at", ascending: false))
        self.tableView.hidden = notifications.count == 0
        self.placeholderLabel.hidden = notifications.count != 0
        
        self.notificationsActiveModel.addItems(notifications, cellIdentifier: String(NotificationsTableViewCell), sectionTitle: nil, delegate: self)
        self.notificationsDataSource.reloadTable()
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.retrieveNotifications(true, success: { [weak self] (response) in
            NotificationsManager.saveNotificationItems(response as! [String: AnyObject])
            self?.tableView.ins_endPullToRefresh()
            self?.loadItemsFromDB()
            
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.tableView.ins_endPullToRefresh()
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    func setupPullToRefresh() {
        self.tableView.ins_addPullToRefreshWithHeight(NavigationBar.defaultHeight) { [weak self] (scrollView) in
            self?.loadRemoteData()
        }
        
        let pullToRefresh = INSDefaultPullToRefresh(frame: Frame.pullToRefreshFrame, backImage: nil, frontImage: nil)
        self.tableView.ins_pullToRefreshBackgroundView.preserveContentInset = false
        self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh
        self.tableView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh)
        self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
    
    // MARL: - NotificationsCellDelegate
    func openProfile(userId: Int) {
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
    func openNotificableItem(notificableItemId: Int) {
        let notification = NotificationsManager.find(notificableItemId)
        if notification.notificable_type == NotificableType.StoryPoint.rawValue {
            self.routesPushFromLeftStoryPointCaptureViewController(notification.notificable_storypoint.id)
        } else if notification.notificable_type == NotificableType.Story.rawValue {
            self.routesPushFromLeftStoryCaptureViewController(notification.notificable_story.id)
        }
    }
}
