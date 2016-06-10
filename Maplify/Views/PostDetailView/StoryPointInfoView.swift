//
//  StoryPointInfoView.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import SDWebImage
import AFImageHelper
import PINRemoteImage.PINImageView_PINRemoteImage
import PINCache

let kEmptyImageViewDefaultHeight: CGFloat = 30
let kInfoViewHeight: CGFloat = 100
let kDetailTextBottomMargin: CGFloat = 10
let kStoriesTableRowHeight: CGFloat = 44
let kStoryPointCellYOffset: CGFloat = 10
let kTextDetailViewMargin: CGFloat = 16
let kBottomTableMargin: CGFloat = 10
let kImageReduceSize: CGFloat = 350

protocol StoryPointInfoViewDelegate: class {
    func profileImageTapped(userId: Int)
    func didSelectStory(storyId: Int)
    func likeStoryPointDidTap(storyPointId: Int, completion: ((success: Bool) -> ()))
    func shareStoryPointDidTap(storyPointId: Int)
    func storyPointMenuButtonTapped(storyPointId: Int)
}

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
    @IBOutlet weak var tableNameLabel: UILabel!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentContentView: UIView!
    @IBOutlet weak var userNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentMediaViewHeight: NSLayoutConstraint!
    
    var storiesLinksActiveModel: CSActiveModel! = nil
    var storiesLinksDataSource: CSBaseTableDataSource! = nil
    var userId: Int = 0
    var storyPointId: Int = 0
    weak var delegate: StoryPointInfoViewDelegate? = nil
    var textHeight: CGFloat = 0
    
    // MARK: - setup
    func configure(storyPoint: StoryPoint, delegate: StoryPointInfoViewDelegate) {
        self.clearData()
        self.clearCache()
        
        self.delegate = delegate
        self.storyPointId = storyPoint.id
        
        self.setupLabels(storyPoint)
        self.setupImageView(storyPoint)
        self.setupUserViews(storyPoint)
        self.setupStoriesTableView(storyPoint)
        self.populateLikeButton(storyPoint)
        self.setupGestures()
        self.setupContentSize()
    }
    
    deinit {
        self.clearData()
    }
    
    func setupLabels(storyPoint: StoryPoint) {
        if storyPoint.location.address.length > 0 {
            self.addressLabel.text = storyPoint.location.address
        } else {
            let location = MCMapCoordinate(latitude: storyPoint.location.latitude, longitude: storyPoint.location.longitude)
            self.addressLabel.text = self.generateLocationString(location)
        }
        self.detailsTextView.text = storyPoint.text
        
        let width = UIScreen.mainScreen().bounds.width - 2 * (kCellHorizontalMargin + kTextDetailViewMargin)
        
        self.textHeight = storyPoint.text.size(self.detailsTextView.font!, boundingRect: CGRectMake(0, 0, width, CGFloat.max)).height + kDetailTextBottomMargin
        
        self.tableNameLabel.hidden = !(storyPoint.storiesLinks.count > 0)
    }
    
    func setupImageView(storyPoint: StoryPoint) {
        if storyPoint.kind == StoryPointKind.Text.rawValue {
            self.userNameLabelTopConstraint.constant = 0
            self.colorView.hidden = true
            self.imageViewHeightConstraint.constant = kEmptyImageViewDefaultHeight
        } else {
            self.imageViewHeightConstraint.constant = CGRectGetWidth(self.frame)
            self.contentMediaViewHeight.constant = CGRectGetWidth(self.frame)
            self.populateAttachment(storyPoint)
        }
    }
    
    func setupUserViews(storyPoint: StoryPoint) {
        let user = storyPoint.user as User
        let profile = user.profile as Profile
        self.userId = user.id
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        
        self.userImageView.pin_setImageFromURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryPointInfoView.profileImageTapped))
        self.userImageView.addGestureRecognizer(tapGesture)
        
        self.backUserImageView.image = UIImage(color: UIColor.whiteColor())?.roundCornersToCircle()
        self.backUserImageView.layer.cornerRadius = CGRectGetHeight(self.backUserImageView.frame) / 2
        self.backUserImageView.layer.masksToBounds = true
        
        self.userImageView.layer.cornerRadius = CGRectGetHeight(self.backUserImageView.frame) / 2
        self.userImageView.layer.masksToBounds = true
        
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryPointInfoView.openContentTapHandler(_:)))
        self.attachmentContentView?.addGestureRecognizer(tapGesture)
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
        
        self.storyPointImageView.pin_setImageFromURL(attachmentUrl, placeholderImage: placeholderImage)
    }
    
    func populateImage(storyPoint: StoryPoint, error: NSError!) {
        if error == nil {
            self.colorView?.alpha = storyPoint.kind == StoryPointKind.Photo.rawValue ? 0.0 : kMapImageDownloadCompletedAlpha
        }
        self.populateKindImage(storyPoint)
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
            self.storiesLinksActiveModel = CSActiveModel()
            self.storiesLinksActiveModel.addItems(Array(storyPoint.storiesLinks), cellIdentifier: String(StoryLinkCell), sectionTitle: nil, delegate: self)
            self.storiesLinksDataSource = CSBaseTableDataSource(tableView: self.storiesTableView, activeModel: self.storiesLinksActiveModel, delegate: self)
            self.tableViewHeightConstraint.constant = CGFloat(self.storiesLinksActiveModel.numberOfItems(0)) * kStoriesTableRowHeight
            self.storiesLinksDataSource.reloadTable()
        }
    }
    
    func setupContentSize() {
        self.scrollView.delegate = self
        let contentHeight = self.imageViewHeightConstraint.constant + self.textHeight + kInfoViewHeight + self.tableViewHeightConstraint.constant + kStoryPointCellYOffset + kBottomTableMargin
        self.scrollView.contentSize = CGSizeMake(0, contentHeight)
        self.contentViewHeightConstraint.constant = contentHeight
    }
    
    func populateLikeButton(storyPoint: StoryPoint) {
        if storyPoint.liked {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLikeHighlited), forState: .Normal)
        } else {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLike), forState: .Normal)
        }
    }
    
    // MARK: - actions
    func profileImageTapped() {
        self.delegate?.profileImageTapped(self.userId)
    }
    
    override func layoutSubviews() {
        self.setupContentSize()
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        self.likeButton.enabled = false
        self.delegate?.likeStoryPointDidTap(self.storyPointId, completion: { [weak self] (success) in
            self?.likeButton.enabled = true
            if success {
                let storyPoint = StoryPointManager.find((self?.storyPointId)!)
                self?.populateLikeButton(storyPoint)
            }
        })
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        self.delegate?.storyPointMenuButtonTapped(self.storyPointId)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        self.delegate?.shareStoryPointDidTap(self.storyPointId)
    }
    
    func openContentTapHandler(gestureRecognizer: UIGestureRecognizer) {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint?.kind == StoryPointKind.Video.rawValue {
            PlayerHelper.sharedPlayer.playVideo((storyPoint?.attachment.file_url)!, onView: self.attachmentContentView)
        } else if storyPoint?.kind == StoryPointKind.Audio.rawValue {
            PlayerHelper.sharedPlayer.playAudio((storyPoint?.attachment?.file_url)!, onView: self.attachmentContentView)
        }
        self.attachmentContentView.hidden = storyPoint?.kind == StoryPointKind.Text.rawValue || storyPoint?.kind == StoryPointKind.Photo.rawValue
    }
    
    func clearData() {
        self.storyPointImageView?.image = nil
        self.userImageView?.image = nil
        self.backUserImageView?.image = nil
        self.storiesLinksActiveModel?.removeData()
        self.storiesLinksActiveModel = nil
        self.storiesLinksDataSource = nil
    }
    
    func clearCache() {
        PINRemoteImageManager.sharedImageManager().defaultImageCache().removeAllObjects()
    }
    
    // MARK: - CSBaseTableDataSourceDelegate
    func didSelectModel(model: AnyObject, selection: Bool, indexPath: NSIndexPath) {
        self.delegate?.didSelectStory((model as! StoryLink).id)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y)
    }
}
