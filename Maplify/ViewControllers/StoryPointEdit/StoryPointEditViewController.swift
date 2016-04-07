//
//  StoryPointEditViewController.swift
//  Maplify
//
//  Created by jowkame on 05.04.16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class StoryPointEditViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var storyView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var storyPointImageView: UIImageView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    var editInfoViewController: StoryPointEditInfoViewController! = nil
    var storyPointId: Int = 0
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupContentHeight()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupEditStoryPointInfoViewController()
        self.addRightBarItem(NSLocalizedString("Button.Save", comment: String()))
        self.setupContent()
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
    
    func setupEditStoryPointInfoViewController() {
        let identifier = Controllers.storyPointEditInfoViewController
        self.editInfoViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(identifier) as! StoryPointEditInfoViewController
        self.configureChildViewController(self.editInfoViewController, onView: self.storyView)
        self.editInfoViewController.configure(self.storyPointId)
    }
    
    func setupContent() {
        let storyPoint = StoryPointManager.find(self.storyPointId)
        if storyPoint.attachment != nil {
            let attachmentUrl = NSURL(string: storyPoint.attachment.file_url)
            self.storyPointImageView.sd_setImageWithURL(attachmentUrl)
        }
    }
    
    func setupContentHeight() {
        let updatedHeight = CGRectGetHeight(self.editInfoViewController.view.frame) + self.contentScrollView.contentSize.height
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
    override func rightBarButtonItemDidTap() {
        self.showProgressHUD()
        
        let storyPointDict: [String: AnyObject] = ["caption": self.editInfoViewController.captionTextField.text!]
        
        ApiClient.sharedClient.updateStoryPoint(self.storyPointId, params: storyPointDict, success: { [weak self] (response) -> () in
            StoryPointManager.saveStoryPoint(response as! StoryPoint)
            self?.hideProgressHUD()
            self?.navigationController?.popToRootViewControllerAnimated(true)
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