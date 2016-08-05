//
//  StoryPointEditViewController.swift
//  Maplify
//
//  Created by jowkame on 05.04.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

let kDefaultDescriptionViewHeight: CGFloat = 45
let kDescriptionHorizontalPadding: CGFloat = 10
let kCharactersCountLabelHeight: CGFloat = 45

class StoryPointEditViewController: ViewController, UITextViewDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var storyView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var charsNumberLabel: UILabel!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailEditView: UIView!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var detailEditViewHeight: NSLayoutConstraint!
    @IBOutlet weak var charactersNumberLabelViewHeight: NSLayoutConstraint!
    @IBOutlet weak var storyPointKindImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var desriptionInputTextView: UITextView!
    
    var editInfoViewController: StoryPointEditInfoViewController! = nil
    var storyPointId: Int = 0
    var storyPoint: StoryPoint! = nil
    var storyPointUpdateHandler: (() -> ())? = nil
    var keyboardHeight: CGFloat = 0
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupContent()
        self.setupContentHeight(false)
    }
    
    deinit {
        self.unsubscribeNotifications()
    }
    
    // MARK: - setup
    func setup() {
        self.loadItemFromDB()
        self.subscribeNotifications()
        self.setupNavigationBar()
        self.setupEditStoryPointInfoViewController()
        self.setupShowDescriptionButton()
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
        self.setupGesture()
        self.setupStories()
        self.setupDesriptionInputTextView()
    }
    
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StoryPointEditViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setupDesriptionInputTextView() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        self.desriptionInputTextView.delegate = self
        self.desriptionInputTextView.text = storyPoint.text
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.EditPost.Title", comment: String())
        
        // add shadow
        self.navigationController!.navigationBar.layer.shadowOpacity = kDiscoverNavigationBarShadowOpacity;
        self.navigationController!.navigationBar.layer.shadowOffset = CGSizeZero;
        self.navigationController!.navigationBar.layer.shadowRadius = kDiscoverNavigationBarShadowRadius;
        self.navigationController!.navigationBar.layer.masksToBounds = false;
    }
    
    func setupShowDescriptionButton() {
        self.descriptionButton.setImage(UIImage(named: ButtonImages.icoBottom), forState: .Normal)
        self.descriptionButton.setImage(UIImage(named: ButtonImages.icoTop), forState: .Highlighted)
        self.descriptionButton.setImage(UIImage(named: ButtonImages.icoTop), forState: .Selected)
        self.descriptionButton.setImage(UIImage(named: ButtonImages.icoTop), forState: [.Highlighted, .Selected])
    }
    
    func setupEditStoryPointInfoViewController() {
        let identifier = Controllers.storyPointEditInfoViewController
        self.editInfoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(identifier) as! StoryPointEditInfoViewController
        self.editInfoViewController.updateContentClosure = { [weak self] () in
            self?.setupContentHeight((self?.descriptionButton.selected)!)
        }
        self.editInfoViewController.keyboardAvoidingModeEnabled = false
        self.configureChildViewController(self.editInfoViewController, onView: self.storyView)
        self.editInfoViewController.tableView.scrollEnabled = false
        self.editInfoViewController.configure(self.storyPointId)
    }
    
    func setupContent() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint != nil {
            if  storyPoint.attachment != nil {
                self.populateAttachment(storyPoint)
                self.charactersNumberLabelViewHeight.constant = 0
                self.charactersCountLabel.hidden = true
            } else {
                self.colorView.hidden = true
                self.storyPointImageView.hidden = true
                self.storyPointImageView.hidden = true
                self.setupDescriptionInputField(storyPoint)
            }
            
            if storyPoint.text.length > 0 {
                let ofStr = NSLocalizedString("Substring.Of", comment: String())
                let charsStr = NSLocalizedString("Substring.Chars", comment: String())
                self.charsNumberLabel.text = "\(storyPoint.text.length) " + ofStr + " \(kDescriptionTextViewMaxCharactersCount) " + charsStr
            }
        }
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

    func setupStories() {
        self.showProgressHUD(self.editInfoViewController.tableView)
        ApiClient.sharedClient.getStoryPointStories(self.storyPointId, success: { [weak self] (response) in
            self?.hideProgressHUD((self?.editInfoViewController.tableView)!)
            let stories = response as! [Story]
            self?.editInfoViewController.configureSelectedStories(stories)
            self?.setupContentHeight(false)
            },
            failure: { [weak self] (statusCode, errors, localDescription, messages) in
                self?.hideProgressHUD((self?.editInfoViewController.tableView)!)
                self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            })
    }
    
    func setupDescriptionInputField(storyPoint: StoryPoint) {
        self.descriptionView.hidden = true
        self.descriptionTextView.delegate = self
        self.descriptionTextView.text = storyPoint.text
        self.updateCharactersCountLabel(storyPoint.text.length)
    }
    
    func setupContentHeight(expanded: Bool) {
        if (storyPoint.attachment != nil) && expanded {
            self.descriptionViewHeightConstraint.constant = kDefaultDescriptionViewHeight + self.descriptionTextContentHeight()
        }
        let infoHeight = self.editInfoViewController.contentHeight()
        let updatedHeight = infoHeight + self.detailEditViewHeight.constant + self.detailsViewContentHeight() + self.descriptionTextContentHeight()
        self.detailEditViewHeight.constant = self.detailsViewContentHeight()
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.contentSize.width, updatedHeight)
        self.contentViewHeightConstraint.constant = updatedHeight
    }
    
    func descriptionTextContentHeight() -> CGFloat {
        let boundingRect = CGRectMake(0, 0, CGRectGetWidth(self.desriptionInputTextView.frame) , CGFloat.max)
        return self.desriptionInputTextView.text.size(self.desriptionInputTextView.font!, boundingRect: boundingRect).height + 2 * kDescriptionHorizontalPadding
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    func loadItemFromDB() {
        self.storyPoint = StoryPointManager.find(self.storyPointId)
    }
    
    // MARK: - notifications/observers
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoryPointEditDescriptionViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - actions
    func dismissKeyboard() {
        self.descriptionTextView.resignFirstResponder()
        self.desriptionInputTextView.resignFirstResponder()
    }
    
    @IBAction func showDescriptionButtonTapped(sender: AnyObject) {
        self.descriptionButton.selected = !self.descriptionButton.selected
        self.showStoryPointDescription()
    }
    
    func showStoryPointDescription() {
        let boundingRect = CGRectMake(0, 0, CGRectGetWidth(self.desriptionInputTextView.frame) , CGFloat.max)
        let textHeight = self.desriptionInputTextView.text.size(self.desriptionInputTextView.font!, boundingRect: boundingRect).height + 2 * kDescriptionHorizontalPadding
        
        self.desriptionInputTextView.hidden = !self.descriptionButton.selected
        
        if self.descriptionButton.selected {
            self.descriptionViewHeightConstraint.constant = kDefaultDescriptionViewHeight + textHeight
        } else {
            self.desriptionInputTextView.resignFirstResponder()
            self.descriptionViewHeightConstraint.constant = kDefaultDescriptionViewHeight
        }
        
        self.setupContentHeight(self.descriptionButton.selected)
    }

    override func rightBarButtonItemDidTap() {
        self.showProgressHUD()
        
        let locationDict: [String: AnyObject] = ["latitude":self.storyPoint.location.latitude,
                                                 "longitude": self.storyPoint.location.longitude,
                                                 "address": self.editInfoViewController.placeOrLocationTextField.text!]
        let kind = self.storyPoint.kind
        
        var text = String()
        if self.storyPoint.attachment != nil {
            text = self.desriptionInputTextView.text
        } else {
            text = self.descriptionTextView.text
        }
        
        var storyPointDict: [String: AnyObject] = ["kind": kind,
                                                   "text": text,
                                                   "location":locationDict]
        
        let selectedStoriesIds = self.editInfoViewController.selectedStories.map({$0.id})
        storyPointDict["story_ids"] = (selectedStoriesIds.count > 0) ? selectedStoriesIds : [Int]()
        
        ApiClient.sharedClient.updateStoryPoint(self.storyPointId, params: storyPointDict, success: { [weak self] (response) -> () in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            
            ApiClient.sharedClient.getUserStories(SessionManager.currentUser().id,
                success: { [weak self] (response) in
                        StoryManager.saveStories(response as! [Story])
                        self?.hideProgressHUD()
                        self?.storyPointUpdateHandler?()
                        self?.navigationController?.popViewControllerAnimated(true)
                }, failure: { [weak self] (statusCode, errors, localDescription, messages) in
                    self?.hideProgressHUD()
                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                })
        }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
            self?.hideProgressHUD()
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView === self.desriptionInputTextView {
            self.setupContentHeight(self.descriptionButton.selected)
            self.scrollToDescriptionTextEnd()
            return self.checkAndUpdateTextView(self.desriptionInputTextView, range: range, text: text)
        } else if textView === self.descriptionTextView {
            return self.checkAndUpdateTextView(self.descriptionTextView, range: range, text: text)
        }
        return false
    }
    
    private func checkAndUpdateTextView(textView: UITextView, range: NSRange, text: String) -> Bool {
        let resultCharactersCount = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text).length
        if resultCharactersCount <= kDescriptionTextViewMaxCharactersCount {
            self.updateCharactersCountLabel(resultCharactersCount)
            return true
        }
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView === self.desriptionInputTextView {
            self.scrollToDescriptionTextEnd()
        }
    }
    
    func scrollToDescriptionTextEnd() {
        let updatedHeight = self.descriptionTextContentHeight() + kDefaultDescriptionViewHeight + 2 * kDescriptionHorizontalPadding
        self.contentScrollView.setContentOffset(CGPointMake(0, updatedHeight), animated: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView === self.descriptionTextView {
            self.detailEditViewHeight.constant = self.detailsViewContentHeight()
            self.setupContentHeight(self.descriptionButton.selected)
            self.contentScrollView.scrollRectToVisible(CGRectMake(0, 0, CGRectGetWidth(self.descriptionView.frame), self.detailsViewContentHeight() + self.keyboardHeight), animated: true)
        }
    }
    
    func detailsViewContentHeight() -> CGFloat {
        var height: CGFloat = 0
        if self.storyPoint.attachment != nil {
            height = CGRectGetWidth(self.view.frame)
        } else {
            let boundingRect = CGRectMake(0, 0, CGRectGetWidth(self.descriptionTextView.frame), CGFloat.max)
            height = self.descriptionTextView.text.size(self.descriptionTextView.font!, boundingRect: boundingRect).height + kCharactersCountLabelHeight + 2 * kDescriptionHorizontalPadding
        }
        return height
    }
    
    func updateCharactersCountLabel(charactersCount: Int) {
        let substringOf = NSLocalizedString("Substring.Of", comment: String())
        let substringChars = NSLocalizedString("Substring.Chars", comment: String())
        self.charactersCountLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
        self.charsNumberLabel.text = "\(charactersCount) " + substringOf + " \(kDescriptionTextViewMaxCharactersCount) " + substringChars
    }
    
    // MARK: - keyboard notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardHeight = keyboardFrame.size.height
    }
   
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}