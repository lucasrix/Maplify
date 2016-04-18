//
//  DiscoverStoryCell.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 4/6/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kStoryCellDescriptionDefaultHeight: CGFloat = 17
let kStoryDescriptionOpened: Int = 0
let kStoryDescriptionClosed: Int = 1

class DiscoverStoryCell: CSTableViewCell, CSBaseCollectionDataSourceDelegate {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backShadowView: UIView!
    @IBOutlet weak var showHideDescriptionLabel: UILabel!
    @IBOutlet weak var showHideDescriptionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var storyPointsPlusView: UIView!
    @IBOutlet weak var storyPointPlusLabel: UILabel!
    
    var cellData: CSCellData! = nil
    var delegate: DiscoverStoryCellDelegate! = nil
    var storyId: Int = 0
    
    var storyPointDataSource: DiscoverStoryCollectionDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    
    // MARK: - setup
    override func configure(cellData: CSCellData) {
        self.cellData = cellData
        self.delegate = cellData.delegate as! DiscoverStoryCellDelegate
        let item = cellData.model as! DiscoverItem
        let story = item.story
        self.storyId = story!.id
        
        self.addShadow()
        self.setupCollectionView(cellData)
        self.populateUserViews(story!)
        self.populateStoryInfoViews(story!)
        self.populateDescriptionLabel(cellData)
        self.setupSwipe()
    }
    
    func addShadow() {
        self.backShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.backShadowView.layer.shadowOpacity = kShadowOpacity
        self.backShadowView.layer.shadowOffset = CGSizeZero
        self.backShadowView.layer.shadowRadius = kShadowRadius
    }
    
    func populateUserViews(story: Story) {
        let user = story.user as User
        let profile = user.profile as Profile

        let userPhotoUrl: NSURL! = NSURL(string: profile.photo)
        let placeholderImage = UIImage(named: PlaceholderImages.discoverUserEmptyAva)
        self.thumbImageView.sd_setImageWithURL(userPhotoUrl, placeholderImage: placeholderImage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DiscoverStoryCell.profileImageTapped))
        self.thumbImageView.addGestureRecognizer(tapGesture)
        
        self.userNameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city
    }
    
    func populateStoryInfoViews(story: Story) {
        self.captionLabel.text = story.title
    }
    
    func populateDescriptionLabel(cellData: CSCellData) {
        self.descriptionLabel.numberOfLines = cellData.selected ? kStoryDescriptionOpened : kStoryDescriptionClosed
        let item = cellData.model as! DiscoverItem
        let story = item.story
        
        self.descriptionLabel.text = story!.storyDescription
        
        if cellData.selected {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(story!.storyDescription)
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(story!.storyDescription)
    }
    
    func setupCollectionView(cellData: CSCellData) {
        self.updateCollectionViewData(cellData)
    }
    
    func updateCollectionViewData(cellData: CSCellData) {
        let item = cellData.model as! DiscoverItem
        let story = item.story
        let storyPoints: [StoryPoint] = Array(story!.storyPoints)
        let itemsToShow: [AnyObject] = [story!] + storyPoints
        self.storyPointActiveModel.removeData()
        self.storyPointActiveModel.addItems(itemsToShow, cellIdentifier: String(), sectionTitle: nil, delegate: self)
        self.storyPointDataSource = DiscoverStoryCollectionDataSource(collectionView: self.collectionView, activeModel: self.storyPointActiveModel, delegate: self)
        self.storyPointDataSource.reloadCollectionView()
        
        let itemsOverlimit = story!.storyPoints.count - self.numberOfStoryPointInCollectionView()
        self.storyPointPlusLabel.text = "+\(itemsOverlimit)"
        self.storyPointsPlusView.hidden = itemsOverlimit == 0
    }
    
    func setupSwipe() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DiscoverStoryCell.handleDetailSwipe(_:)))
        swipeGesture.direction = .Left
        self.contentView.addGestureRecognizer(swipeGesture)
    }
    
    func handleDetailSwipe(sender:UISwipeGestureRecognizer) {
        let item = cellData.model as! DiscoverItem
        let story = item.story
        self.delegate?.didSelectStoryPoint(Array(story!.storyPoints), selectedIndex: 0, storyTitle: story!.title)
    }
    
    func numberOfStoryPointInCollectionView() -> Int {
        return self.collectionView.numberOfItemsInSection(0) - 1
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.cellData.selected = !self.cellData.selected
        self.delegate?.didSelectStory(self.storyId)
    }
    
    func profileImageTapped() {
        let story = cellData.model as! Story
        self.delegate?.storyProfileImageTapped(story.user.id)
    }
    
    // MARK: - private
    func showHideButtonHidden(text: String) -> Bool {
        let font = self.descriptionLabel.font
        let textWidth: CGFloat = CGRectGetWidth(self.descriptionLabel.frame)
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        return textSize.height <= kStoryCellDescriptionDefaultHeight
    }
    
    // MARK: - CSBaseCollectionDataSourceDelegate
    func didSelectModel(model: AnyObject, indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.delegate?.didSelectMap()
        } else {
            let item = cellData.model as! DiscoverItem
            let story = item.story
            self.delegate?.didSelectStoryPoint(Array(story!.storyPoints), selectedIndex: indexPath.row - 1, storyTitle: story!.title)
        }
    }
    
    // MARK: - content height
    class func contentSize(cellData: CSCellData) -> CGSize {
        let contentWidth: CGFloat = cellData.boundingSize.width
        var contentHeight: CGFloat = kTopInfoViewHeight + kBottomInfoView
        
        let item = cellData.model as! DiscoverItem
        let story = item.story
        
        let cellWidth = DiscoverStoryCell.cellWidth((story?.storyPoints.count)!)
        let rowsCount = DiscoverStoryCell.itemsCountToShow((story?.storyPoints.count)! + 1).1        
        contentHeight += (cellWidth * CGFloat(rowsCount))
        
        if cellData.selected {
            contentHeight += DiscoverStoryCell.textDescriptionHeight((story?.storyDescription)!, width: contentWidth)
        } else {
            contentHeight += kStoryPointCellDescriptionDefaultHeight
        }
        
        contentHeight += kStoryPointTextVerticalMargin
        return CGSizeMake(contentWidth, contentHeight)
    }
    
    class func textDescriptionHeight(text: String, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFontOfSize(kStoryPointTextFontSize)
        let textBoundingWidth = width - 2 * kStoryPointTextHorizontalMargin
        return text.size(font, boundingRect: CGRect(x: 0, y: 0, width: textBoundingWidth, height: CGFloat.max)).height
    }
    
    class  func cellWidth(itemsCount: Int) -> CGFloat {
        let numberOfColumn = self.itemsCountToShow(itemsCount + 1).0 == kDiscoverStoryDataNumberOfItemsInColumnTwo ? kDiscoverStoryDataNumberOfItemsInColumnTwo : kDiscoverStoryDataNumberOfItemsInColumnThree
        let totalCellsLayer: CGFloat = (CGFloat(numberOfColumn) - 1) * kDiscoverStoryDataSourceCellsLayerWidth
        return (UIScreen.mainScreen().bounds.size.width - totalCellsLayer) / CGFloat(numberOfColumn)
    }
    
    class func itemsCountToShow(itemsCount: Int) -> (Int, Int) {
        switch itemsCount {
        case 1:
            return (kDiscoverStoryDataSourceItemsCountToShowOne, 1)
        case 2:
            return (kDiscoverStoryDataSourceItemsCountToShowTwo, 1)
        case 3, 4, 5:
            return (kDiscoverStoryDataSourceItemsCountToShowThree, 1)
        case 6, 7, 8:
            return (kDiscoverStoryDataSourceItemsCountToShowSix, 2)
        default:
            return (kDiscoverStoryDataSourceItemsCountToShowNine, 3)
        }
    }
}

protocol DiscoverStoryCellDelegate {
    func didSelectStory(storyId: Int)
    func didSelectStoryPoint(storyPoints: [StoryPoint], selectedIndex: Int, storyTitle: String)
    func didSelectMap()
    func storyProfileImageTapped(userId: Int)
}
