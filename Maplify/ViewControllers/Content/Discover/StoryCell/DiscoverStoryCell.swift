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
        let story = cellData.model as! Story
        self.storyId = story.id
        
        self.addShadow()
        self.populateUserViews(story)
        self.populateStoryInfoViews(story)
        self.populateDescriptionLabel(cellData)
        self.setupCollectionView(story)
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

        self.userNameLabel.text = profile.firstName + " " + profile.lastName
        self.userAddressLabel.text = profile.city != "" ? profile.city : "Washington DC"
    }
    
    func populateStoryInfoViews(story: Story) {
        self.captionLabel.text = story.title
    }
    
    func populateDescriptionLabel(cellData: CSCellData) {
        self.descriptionLabel.numberOfLines = cellData.selected ? kStoryDescriptionOpened : kStoryDescriptionClosed
        let story = cellData.model as! Story
        
        let uuu = "unf uwufuwhfuwqufuwqhfuhqwuhfuihqwuihfuiqhwufuhqh ufhwyuq hfuy hwuy fguw qghfgwhj egfhjweg hwgef"
        self.descriptionLabel.text = uuu//story.storyDescription
        
        if cellData.selected {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.HideDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionUp), forState: .Normal)
        } else {
            self.showHideDescriptionLabel.text = NSLocalizedString("Label.ShowDescription", comment: String())
            self.showHideDescriptionButton.setImage(UIImage(named: ButtonImages.discoverShowHideDescriptionDown), forState: .Normal)
        }
        
        self.showHideDescriptionLabel.hidden = self.showHideButtonHidden(uuu)
        self.showHideDescriptionButton.hidden = self.showHideButtonHidden(uuu)
    }
    
    func setupCollectionView(story: Story) {
        self.updateCollectionViewData(story)
    }
    
    func updateCollectionViewData(story: Story) {
        let storyPoints: [StoryPoint] = Array(story.storyPoints)
        let itemsToShow: [AnyObject] = [story] + storyPoints
        self.storyPointActiveModel.addItems(itemsToShow, cellIdentifier: String(), sectionTitle: nil, delegate: self)
        self.storyPointDataSource = DiscoverStoryCollectionDataSource(collectionView: self.collectionView, activeModel: self.storyPointActiveModel, delegate: self)
        
        let itemsOverlimit = story.storyPoints.count - self.numberOfStoryPointInCollectionView()
        self.storyPointPlusLabel.text = "+\(itemsOverlimit)"
        self.storyPointsPlusView.hidden = itemsOverlimit == 0
    }
    
    func setupSwipe() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(DiscoverStoryCell.handleDetailSwipe(_:)))
        swipeGesture.direction = .Left
        self.contentView.addGestureRecognizer(swipeGesture)
    }
    
    func handleDetailSwipe(sender:UISwipeGestureRecognizer) {
        // TODO:
        print(sender.direction)
    }
    
    func numberOfStoryPointInCollectionView() -> Int {
        return self.collectionView.numberOfItemsInSection(0) - 1
    }
    
    // MARK: - actions
    @IBAction func showHideTapped(sender: UIButton) {
        self.cellData.selected = !self.cellData.selected
        self.delegate?.didSelectStory(self.storyId)
    }
    
    // MARK: - private
    func showHideButtonHidden(text: String) -> Bool {
        let font = self.descriptionLabel.font
        let textWidth: CGFloat = CGRectGetWidth(self.descriptionLabel.frame)
        let textRect = CGRectMake(0.0, 0.0, textWidth, 0.0)
        let textSize = text.size(font, boundingRect: textRect)
        print(textSize.height)
        return textSize.height <= kStoryCellDescriptionDefaultHeight
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
        // need to use to set the preferredMaxLayoutWidth below.
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
        // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
        self.userNameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.userNameLabel.frame)
        self.captionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.captionLabel.frame)
        self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame)
    }
    
    // MARK: - CSBaseCollectionDataSourceDelegate
    func didSelectModel(model: AnyObject, indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.delegate?.didSelectMap()
        } else {
            let storyPoint = model as! StoryPoint
            self.delegate?.didSelectStoryPoint(storyPoint.id)
        }
    }
}

protocol DiscoverStoryCellDelegate {
    func didSelectStory(storyId: Int)
    func didSelectStoryPoint(storyPointId: Int)
    func didSelectMap()
}
