//
//  FollowingViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/12/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import RealmSwift
import UIKit

class FollowingViewController: ViewController, FollowingCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var followingsDataSource: CSBaseTableDataSource! = nil
    var followingsActiveModel = CSActiveModel()

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
        self.followingsDataSource = CSBaseTableDataSource(tableView: self.tableView, activeModel: self.followingsActiveModel, delegate: self)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadItemsFromDB() {
        self.followingsActiveModel.removeData()
        
        let realm = try! Realm()
        let followings = Array(realm.objects(User).filter("followed == true").sorted("created_at"))
        
        self.followingsActiveModel.addItems(followings, cellIdentifier: String(FollowingTableViewCell), sectionTitle: nil, delegate: self)
        self.followingsDataSource.reloadTable()
    }
    
    func loadRemoteData() {
        ApiClient.sharedClient.retrieveFollowingsList({ [weak self] (response) in
            UserListManager.saveFollowings(response as! [User])
            self?.loadItemsFromDB()
            
        }) { [weak self] (statusCode, errors, localDescription, messages) in
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - FollowingCellDelegate
    func followUser(userId: Int, completion: ((success: Bool) -> ())!) {
        let user = SessionManager.findUser(userId)
        if user.followed {
            self.showUnfollowAlert(userId, completion: completion)
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
    
    func showUnfollowAlert(userId: Int, completion: ((success: Bool) -> ())) {
        self.askForUnfollow(userId) { [weak self] (selectedButtonIndex) in
            if selectedButtonIndex == ActionSheetButtonIndexes.Destructive.rawValue {
                self?.unfollowUserRemote(userId, completion: completion)
            }
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
