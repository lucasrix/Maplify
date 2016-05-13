//
//  FollowersViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

class FollowersViewController: ViewController, FollowingCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var followersDataSource: CSBaseTableDataSource! = nil
    var followersActiveModel = CSActiveModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.loadRemoteData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadItemsFromDB()
    }
    
    func setup() {
        self.setupDataSource()
    }
    
    func setupDataSource() {
        self.followersDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.followersActiveModel, delegate: self)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadItemsFromDB() {
        self.followersActiveModel.removeData()
        
        let realm = try! Realm()
        let followers = Array(realm.objects(User).filter("follower == true"))
        
        self.followersActiveModel.addItems(followers, cellIdentifier: String(FollowingTableViewCell), sectionTitle: nil, delegate: self)
        self.followersDataSource.reloadTable()
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.retrieveFollowersList({ [weak self] (response) in
            UserListManager.saveFollowers(response as! [User])
            self?.loadItemsFromDB()
            
            }) { [weak self] (statusCode, errors, localDescription, messages) in
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - FollowingCellDelegate
    func followUser(userId: Int, completion: ((success: Bool) -> ())!) {
        let user = SessionManager.findUser(userId)
        if user.followed {
            self.unfollowUserRemote(userId, completion: completion)
        } else {
            self.followUserRemote(userId, completion: completion)
        }
    }
    
    func openProfile(userId: Int) {
        self.routesOpenDiscoverController(userId, supportUserProfile: true, stackSupport: true)
    }
    
    // MARK: - private
    private func followUserRemote(userId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.followUser(userId, success: { (response) in
            SessionManager.saveUser(response as! User)
            completion(success: true)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    private func unfollowUserRemote(userId: Int, completion: ((success: Bool) -> ())) {
        ApiClient.sharedClient.unfollowUser(userId, success: { (response) in
            SessionManager.saveUser(response as! User)
            completion(success: true)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            completion(success: false)
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
