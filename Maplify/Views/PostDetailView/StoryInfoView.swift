//
//  StoryInfoView.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

protocol StoryInfoViewDelegate {
    func storyProfileImageTapped(userId: Int)
    func likeStoryDidTap(storyId: Int, completion: ((success: Bool) -> ()))
    func shareStoryDidTap(storyId: Int)
}

class StoryInfoView: UIView, UIScrollViewDelegate, CSBaseCollectionDataSourceDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var backUserImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyPointPlusLabel: UILabel!
    @IBOutlet weak var storyPointsPlusView: UIView!
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var detailsTextViewHeight: NSLayoutConstraint!
    
    var userId: Int = 0
    var storyId: Int = 0
    var delegate: StoryInfoViewDelegate! = nil
    var storyPointDataSource: DetailStoryItemsDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    var textHeight: CGFloat = 0
    
    // MARK: - setup
    func configure(story: Story, delegate: StoryInfoViewDelegate) {
        self.delegate = delegate
        self.storyId = story.id
        
        self.setupUserViews(story)
        self.updateCollectionViewData(story)
        self.populateLikeButton(story)
        self.setupAddressLabel(story)
    }
    
    func setupUserViews(story: Story) {
        let user = story.user as User
        let profile = user.profile as Profile
        self.userId = user.id
        
        self.storyTitleLabel.text = story.title
        
        let userPhotoUrl: NSURL! = NSURL(string: profile.small_thumbnail)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.userImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryInfoView.profileImageTapped))
        self.userImageView.addGestureRecognizer(tapGesture)
        
        self.backUserImageView.image = UIImage(color: UIColor.whiteColor())?.roundCornersToCircle()
        self.backUserImageView.layer.cornerRadius = CGRectGetHeight(self.backUserImageView.frame) / 2
        self.backUserImageView.layer.masksToBounds = true
        
        self.detailsTextView.text = story.storyDescription
        
        self.detailsTextViewHeight.constant = story.storyDescription.size(self.detailsTextView.font!, boundingRect: CGRectMake(0, 0, CGRectGetWidth(self.detailsTextView.frame), CGFloat.max)).height
        
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
    }
    
    func setupAddressLabel(story: Story) {
        let user = story.user as User
        let profile = user.profile as Profile
        
        if profile.location.address.length > 0 {
            self.addressLabel.text = profile.location.address
        } else {
            let location = MCMapCoordinate(latitude: profile.location.latitude, longitude: profile.location.longitude)
            self.addressLabel.text = self.generateLocationString(location)
        }
    }
    
    func generateLocationString(location: MCMapCoordinate!) -> String {
        if location != nil {
            return String(format: NSLocalizedString("Label.LatitudeLongitude", comment: String()), location.latitude, location.longitude)
        }
        return String()
    }
    
    func populateLikeButton(story: Story) {
        if story.liked {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLikeHighlited), forState: .Normal)
        } else {
            self.likeButton.setImage(UIImage(named: ButtonImages.discoverLike), forState: .Normal)
        }
    }
    
    func updateCollectionViewData(story: Story) {
        self.collectionView.registerClass(DetailStoryNumberCell.self, forCellWithReuseIdentifier: String(DetailStoryNumberCell))
        self.collectionView.registerNib(UINib(nibName: String(DetailStoryNumberCell), bundle: nil), forCellWithReuseIdentifier: String(DetailStoryNumberCell))
        
        self.collectionView.registerClass(DetailStoryPointCollectionCell.self, forCellWithReuseIdentifier: String(DetailStoryPointCollectionCell))
        self.collectionView.registerNib(UINib(nibName: String(DetailStoryPointCollectionCell), bundle: nil), forCellWithReuseIdentifier: String(DetailStoryPointCollectionCell))
        
        let storyPoints: [StoryPoint] = Array(story.storyPoints)
        let itemsToShow: [AnyObject] = [story] + storyPoints
        self.storyPointActiveModel.removeData()
                
        self.storyPointActiveModel.addItems(itemsToShow, cellIdentifier: String(), sectionTitle: nil, delegate: self, boundingSize: CGSizeMake(CGRectGetWidth(self.scrollView.frame), 0))
        self.storyPointDataSource = DetailStoryItemsDataSource(collectionView: self.collectionView, activeModel: self.storyPointActiveModel, delegate: self)
        self.storyPointDataSource.reloadCollectionView()
        
        let itemsOverlimit = story.storyPoints.count - self.numberOfStoryPointInCollectionView()
        self.storyPointPlusLabel.text = "+\(itemsOverlimit)"
        self.storyPointsPlusView.hidden = itemsOverlimit == 0
        
        let rowsCount = self.storyItemsCountToShow(story.storyPoints.count + 1).1
        let numberOfColumn = self.storyItemsCountToShow(story.storyPoints.count + 1).0 == kDiscoverStoryDataNumberOfItemsInColumnTwo ? kDiscoverStoryDataNumberOfItemsInColumnTwo : kDiscoverStoryDataNumberOfItemsInColumnThree
        
        let cellWidth = ((UIScreen.mainScreen().bounds.width - 2 * kCellHorizontalMargin) - kDiscoverStoryDataSourceCellsLayerWidth) / CGFloat(numberOfColumn)
        let contentHeight = (cellWidth * CGFloat(rowsCount))
        self.collectionViewHeightConstraint.constant = contentHeight
    }
    
    func storyItemsCountToShow(itemsCount: Int) -> (Int, Int) {
        switch itemsCount {
        case 1:
            return (kDiscoverStoryDataSourceItemsCountToShowOne, kDiscoverStoryDataSourceNumberOfRowsOne)
        case 2:
            return (kDiscoverStoryDataSourceItemsCountToShowTwo, kDiscoverStoryDataSourceNumberOfRowsOne)
        case 3, 4, 5:
            return (kDiscoverStoryDataSourceItemsCountToShowThree, kDiscoverStoryDataSourceNumberOfRowsOne)
        case 6, 7, 8:
            return (kDiscoverStoryDataSourceItemsCountToShowSix, kDiscoverStoryDataSourceNumberOfRowsTwo)
        default:
            return (kDiscoverStoryDataSourceItemsCountToShowNine, kDiscoverStoryDataSourceNumberOfRowsThree)
        }
    }
    
    override func layoutSubviews() {
        self.setupContentSize()
    }
    
    func numberOfStoryPointInCollectionView() -> Int {
        return self.collectionView.numberOfItemsInSection(0) - 1
    }
    
    // MARK: - actions
    func profileImageTapped() {
        self.delegate?.storyProfileImageTapped(self.userId)
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        self.delegate?.likeStoryDidTap(self.storyId, completion: { [weak self] (success) in
            if success {
                let story = StoryManager.find((self?.storyId)!)
                self?.populateLikeButton(story)
            }
        })
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        self.delegate?.shareStoryDidTap(self.storyId)
    }
      
    func setupContentSize() {
        self.scrollView.delegate = self
        
        let updatedHeight = self.detailsTextViewHeight.constant + self.collectionViewHeightConstraint.constant + kInfoViewHeight + kDetailTextBottomMargin
        self.scrollView.contentSize = CGSizeMake(0, updatedHeight)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y)
    }
}