//
//  OnboardCaptureController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

class OnboardCaptureController: ViewController {
    
    @IBOutlet weak var captureTitle: UILabel!
    @IBOutlet weak var captureDescription: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionRightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupConstraints()
        self.setupTitle()
        self.setupDescription()
    }
    
    // MARK: - private
    func setupConstraints() {
        if UIScreen().isIPhoneScreenSize4_0() {
            self.topConstraint.constant = kTopPaddingIPhone4_0
            self.titleTopConstraint.constant = kTitleTopPaddingIPhone4_0
            self.descriptionLeftConstraint.constant = kDescriptionLeftRightPaddingIPhone4_0
            self.descriptionRightConstraint.constant = kDescriptionLeftRightPaddingIPhone4_0
        }
    }
    
    func setupTitle() {
        self.captureTitle.text = NSLocalizedString("Controller.Onboard.Capture.Title", comment: String())
    }
    
    func setupDescription() {
        if UIScreen().isIPhoneScreenSize5_5() {
            self.captureDescription.font = UIFont.systemFontOfSize(kDescriptionLabelFontSizeIPhone5_5 as CGFloat)
        }
        self.captureDescription.text = NSLocalizedString("Controller.Onboard.Capture.Description", comment: String())
    }
}
