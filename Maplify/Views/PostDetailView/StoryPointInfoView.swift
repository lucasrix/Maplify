//
//  StoryPointInfoView.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kEmptyImageViewDefaultHeight: CGFloat = 30
let kInfoViewHeight: CGFloat = 200
let kDetailTextBottomMargin: CGFloat = 10
let kStoriesTableRowHeight: CGFloat = 44

class StoryPointInfoView: UIView, UIScrollViewDelegate, CSBaseTableDataSourceDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var storiesTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backUserImageView: UIImageView!
    @IBOutlet weak var detailTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableNameLabel: UILabel!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    
    var storiesLinksActiveModel = CSActiveModel()
    var storiesLinksDataSource: CSBaseTableDataSource! = nil
    
    // MARK: - setup
    func configure(storyPoint: StoryPoint) {
        self.setupLabels(storyPoint)
        self.setupImageView(storyPoint)
        self.setupUserViews(storyPoint)
        self.setupStoriesTableView(storyPoint)
        self.setupContentSize()
    }
    
    func setupLabels(storyPoint: StoryPoint) {
        if storyPoint.location.address.length > 0 {
            self.addressLabel.text = storyPoint.location.address
        } else {
            let location = MCMapCoordinate(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
            self.addressLabel.text = self.generateLocationString(location)
        }
        self.detailsTextView.text = storyPoint.text
        self.detailTextViewHeight.constant = storyPoint.text.size(self.detailsTextView.font!, boundingRect: CGRectMake(0, 0, CGRectGetWidth(self.detailsTextView.frame), CGFloat.max)).height + kDetailTextBottomMargin
        
        self.tableNameLabel.hidden = !(storyPoint.storiesLinks.count > 0)
    }
    
    func setupImageView(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.imageViewHeightConstraint.constant = kEmptyImageViewDefaultHeight
        } else {
            self.imageViewHeightConstraint.constant = CGRectGetWidth(self.frame)
            self.populateAttachment(storyPoint)
        }
    }
    
    func setupUserViews(storyPoint: StoryPoint) {
        let user = storyPoint.user as User
        let profile = user.profile as Profile
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.userImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryPointInfoView.profileImageTapped))
        self.userImageView.addGestureRecognizer(tapGesture)
        
        self.backUserImageView.image = UIImage(color: UIColor.whiteColor())?.roundCornersToCircle()
        self.backUserImageView.layer.cornerRadius = CGRectGetHeight(self.backUserImageView.frame) / 2
        self.backUserImageView.layer.masksToBounds = true
        
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
    }
    
    func populateAttachment(storyPoint: StoryPoint) {
        var attachmentUrl: NSURL! = nil
        var placeholderImage = UIImage(named: PlaceholderImages.discoverPlaceholder)
        if storyPoint.kind == StoryPointKind.Photo.rawValue {
            attachmentUrl = storyPoint.attachment.file_url.url
        } else if storyPoint.kind == StoryPointKind.Text.rawValue {
            attachmentUrl = nil
            placeholderImage = nil
        } else {
            attachmentUrl = StaticMap.staticMapUrl(storyPoint.location.latitude, longitude: storyPoint.location.longitude, sizeWidth: StaticMapSize.widthLarge, showWholeWorld: false)
        }
        self.storyPointImageView.sd_setImageWithURL(attachmentUrl, placeholderImage: placeholderImage) { [weak self] (image, error, cacheType, url) in
            if error == nil {
                self?.colorView.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
            }
            self?.populateKindImage(storyPoint)
        }
    }
    
    func populateKindImage(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.storyPointKindImageView.image = nil
        } else if storyPoint.kind == StoryPointKind.Photo.rawValue {
            self.storyPointKindImageView.image = nil
        } else if storyPoint.kind == StoryPointKind.Audio.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconAudio)
        } else if storyPoint.kind == StoryPointKind.Video.rawValue {
            self.storyPointKindImageView.image = UIImage(named: CellImages.discoverStoryPointDetailIconVideo)
        }
        self.storyPointKindImageView.hidden = storyPoint.kind == StoryPointKind.Text.rawValue || storyPoint.kind == StoryPointKind.Photo.rawValue
    }

    func generateLocationString(location: MCMapCoordinate!) -> String {
        if location != nil {
            return String(format: NSLocalizedString("Label.LatitudeLongitude", comment: String()), location.latitude, location.longitude)
        }
        return String()
    }
    
    func setupStoriesTableView(storyPoint: StoryPoint) {
        if storyPoint.storiesLinks.count > 0 {
            self.storiesTableView.registerClass(StoryLinkCell.self, forCellReuseIdentifier: String(StoryLinkCell))
            self.storiesTableView.registerNib(UINib(nibName: String(StoryLinkCell), bundle: nil), forCellReuseIdentifier: String(StoryLinkCell))
            self.storiesLinksActiveModel.addItems(Array(storyPoint.storiesLinks), cellIdentifier: String(StoryLinkCell), sectionTitle: nil, delegate: self)
            self.storiesLinksDataSource = CSBaseTableDataSource(tableView: self.storiesTableView, activeModel: self.storiesLinksActiveModel, delegate: self)
            self.storiesLinksDataSource.reloadTable()
        }
    }
    
    func setupContentSize() {
        self.scrollView.delegate = self
        let contentHeight = self.imageViewHeightConstraint.constant + self.detailTextViewHeight.constant + kInfoViewHeight + CGFloat(self.storiesLinksActiveModel.numberOfItems(0)) * kStoriesTableRowHeight
        self.scrollView.contentSize = CGSizeMake(0, contentHeight)
    }
    
    // MARK: - actions
    func profileImageTapped() {
        //TODO:
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        //TODO:
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        //TODO:
    }
    
    // MARK: - CSBaseTableDataSourceDelegate
    func didSelectModel(model: AnyObject, selection: Bool, indexPath: NSIndexPath) {
        //TODO:
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y)
    }
}
