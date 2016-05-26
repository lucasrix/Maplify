//
//  ReportSuccessViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class ReportSuccessViewController: ViewController {
    @IBOutlet weak var thanksTitleLabel: UILabel!
    @IBOutlet weak var thanksDescriptionLabel: UILabel!
    
    var completionClosure: (() -> ())! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.setupViews()
        self.setupBarButtonItems()
    }
    
    // MARK: - setup
    func setupViews() {
        self.title = NSLocalizedString("Controller.Reports", comment: String())
        self.thanksTitleLabel.text = NSLocalizedString("Label.ReportSuccessTitle", comment: String())
        self.thanksDescriptionLabel.text = NSLocalizedString("Label.ReportSuccessDescription", comment: String())
    }
    
    func setupBarButtonItems() {
        self.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    override func rightBarButtonItemDidTap() {
        self.completionClosure?()
    }
}
