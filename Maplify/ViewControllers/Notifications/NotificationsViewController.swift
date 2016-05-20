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
    
    var notificationsDataSource: CSBaseTableDataSource! = nil
    var notificationsActiveModel = CSActiveModel()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadItemsFromDB()
        self.loadRemoteData()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.ins_removePullToRefresh()
        }
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupDataSource()
        self.setupPullToRefresh()
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
        let notifications = Array(realm.objects(Notification).sorted("created_at", ascending: false))
        
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
        var storyPoints: [StoryPoint]! = nil
        var title = String()
        if notification.notificable_type == NotificableType.StoryPoint.rawValue {
            storyPoints = [notification.notificable_storypoint]
            title = notification.notificable_storypoint.caption
        } else if notification.notificable_type == NotificableType.Story.rawValue {
            storyPoints = Converter.listToArray(notification.notificable_story.storyPoints, type: StoryPoint.self)
            title = notification.notificable_story.title
        }
        self.routesPushFromLeftCaptureViewController(storyPoints, title: title, contentType: .Notification)
    }
}
