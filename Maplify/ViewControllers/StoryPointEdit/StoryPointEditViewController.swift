//
//  StoryPointEditViewController.swift
//  Maplify
//
//  Created by jowkame on 05.04.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

let kDefaultDescriptionViewHeight: CGFloat = 45
let kDescriptionHorizontalPadding: CGFloat = 10

class StoryPointEditViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var storyView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var charsNumberLabel: UILabel!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewTopConstraint: NSLayoutConstraint!
    
    var editInfoViewController: StoryPointEditInfoViewController! = nil
    var editDescriptionViewController: StoryPointEditDescriptionViewController! = nil
    var storyPointId: Int = 0
    var storyPointUpdateHandler: (() -> ())! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupContent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupContentHeight(false)
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupEditStoryPointInfoViewController()
        self.setupShowDescriptionButton()
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
    }
    
    func setupNavigationBar() {
        self.title = NSLocalizedString("Controller.EditPost.Title", comment: String())
        
        // add shadow
        self.navigationController!.navigationBar.backgroundColor = UIColor.blackColor();
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
        self.configureChildViewController(self.editInfoViewController, onView: self.storyView)
        self.editInfoViewController.tableView.scrollEnabled = false
        self.editInfoViewController.configure(self.storyPointId)
    }
    
    func setupContent() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint != nil {
            if  storyPoint.attachment != nil {
                let attachmentUrl = NSURL(string: storyPoint.attachment.file_url)
                self.storyPointImageView.sd_setImageWithURL(attachmentUrl)
            } else {
                self.setupDescriptionInputField(storyPoint)
            }

            if storyPoint.text.length > 0 {
                let ofStr = NSLocalizedString("Substring.Of", comment: String())
                let charsStr = NSLocalizedString("Substring.Chars", comment: String())
                self.charsNumberLabel.text = "\(storyPoint.text.length) " + ofStr + " \(kDescriptionTextViewMaxCharactersCount) " + charsStr
            }
        }
    }
    
    func setupDescriptionInputField(storyPoint: StoryPoint) {
        let identifier = Controllers.storyPointEditDescriptionViewController
        self.editDescriptionViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(identifier) as! StoryPointEditDescriptionViewController
        self.configureChildViewController(self.editDescriptionViewController, onView: self.storyPointImageView)
        self.descriptionView.hidden = true
        self.descriptionViewTopConstraint.constant = -kDefaultDescriptionViewHeight
        self.editDescriptionViewController.descriptionTextView.text = storyPoint.text
        self.editDescriptionViewController.updateCharactersCountLabel(storyPoint.text.length)
    }
    
    func contentHeight(expanded: Bool) -> CGFloat {
        var textHeight: CGFloat = 0
        if expanded {
            let storyPoint = StoryPointManager.find(self.storyPointId)
            self.descriptionLabel.text = storyPoint.text
            let boundingRect = CGRectMake(0, 0, CGRectGetWidth(self.descriptionLabel.frame) , CGFloat.max)
            textHeight += storyPoint.text.size(self.descriptionLabel.font, boundingRect: boundingRect).height + 2 * kDescriptionHorizontalPadding
        }
        return self.storyPointImageView.frame.size.height + kDefaultDescriptionViewHeight + textHeight
    }
    
    func setupContentHeight(expanded: Bool) {
        var descriptionHeight: CGFloat = 0
        if self.editDescriptionViewController != nil {
            descriptionHeight += self.editDescriptionViewController.view.frame.size.height
        } else {
            descriptionHeight += self.contentHeight(expanded)
        }
        
        let infoHeight = self.editInfoViewController.contentHeight()
        let storyTableViewHeight = self.editInfoViewController.tableView.contentSize.height
        let updatedHeight = descriptionHeight + infoHeight + storyTableViewHeight
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.contentSize.width, updatedHeight)
        
        self.contentViewHeightConstraint.constant = updatedHeight
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }

    // MARK: - actions
    @IBAction func showDescriptionButtonTapped(sender: AnyObject) {
        self.descriptionButton.selected = !self.descriptionButton.selected
        self.showStoryPointDescription()
    }
    
    func showStoryPointDescription() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        self.descriptionLabel.text = storyPoint.text
        let boundingRect = CGRectMake(0, 0, CGRectGetWidth(self.descriptionLabel.frame) , CGFloat.max)
        let textHeight = storyPoint.text.size(self.descriptionLabel.font, boundingRect: boundingRect).height + 2 * kDescriptionHorizontalPadding
        
        if self.descriptionButton.selected {
            self.descriptionViewHeightConstraint.constant = CGRectGetHeight(self.descriptionView.frame) + textHeight
        } else {
            self.descriptionViewHeightConstraint.constant = kDefaultDescriptionViewHeight
            self.descriptionLabel.text = String()
        }
        
        self.setupContentHeight(self.descriptionButton.selected)
    }

    override func rightBarButtonItemDidTap() {
        self.showProgressHUD()
        
        let storyPointDict: [String: AnyObject] = ["caption": self.editInfoViewController.captionTextField.text!, "text": self.editDescriptionViewController.descriptionTextView.text]
        
        ApiClient.sharedClient.updateStoryPoint(self.storyPointId, params: storyPointDict, success: { [weak self] (response) -> () in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            self?.hideProgressHUD()
            self?.navigationController?.popToRootViewControllerAnimated(true)
            self?.storyPointUpdateHandler()
        }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
            self?.hideProgressHUD()
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
    }
   
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}