//
//  OnboardDiscoverController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kTopPaddingIPhone4_0: CGFloat = 30
let kTitleTopPaddingIPhone4_0: CGFloat = 30
let kBottomPaddingIPhone4_0: CGFloat = 100
let kDescriptionLeftRightPaddingIPhone4_0: CGFloat = 30
let kDescriptionLabelFontSizeIPhone5_5: CGFloat = 21

class OnboardDiscoverController: ViewController {
    
    @IBOutlet weak var discoverTitle: UILabel!
    @IBOutlet weak var discoverDescription: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
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
            self.bottomConstraint.constant = kBottomPaddingIPhone4_0
            self.descriptionLeftConstraint.constant = kDescriptionLeftRightPaddingIPhone4_0
            self.descriptionRightConstraint.constant = kDescriptionLeftRightPaddingIPhone4_0
        }
    }
    
    func setupTitle() {
        self.discoverTitle.text = NSLocalizedString("Controller.Onboard.Discover.Title", comment: String())
    }
    
    func setupDescription() {
        if UIScreen().isIPhoneScreenSize5_5() {
            self.discoverDescription.font = UIFont.systemFontOfSize(kDescriptionLabelFontSizeIPhone5_5 as CGFloat)
        }
        self.discoverDescription.text = NSLocalizedString("Controller.Onboard.Discover.Description", comment: String())
    }
}
