//
//  OurStoryViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class OurStoryViewController: ViewController, ErrorHandlingProtocol, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadRemoteData()
    }

    // MARK: - setup
    func setup() {
        self.title = NSLocalizedString("Controller.OurStory.Title", comment: String())
        self.webView.delegate = self
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - remote
    func loadRemoteData() {
        self.showProgressHUD(self.view)
        ApiClient.sharedClient.retrieveAbout({ [weak self] (response) in
            let htmlString = (response as! WebContent).html
            self?.webView.loadHTMLString(htmlString, baseURL: nil)
        },
        failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
            self?.hideProgressHUD(self!.webView)
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        })
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.hideProgressHUD(self.webView)
    }
}