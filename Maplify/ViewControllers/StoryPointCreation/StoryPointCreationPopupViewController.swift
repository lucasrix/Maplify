//
//  StoryPointCreationPopupViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/19/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointCreationPopupViewController: ViewController {
    var delegate: StoryPointCreationPopupDelegate! = nil
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var ambientButton: UIButton!
    @IBOutlet weak var photoVideoButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.setupBlur()
        self.setupLabels()
    }
    
    func setupBlur() {
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = view.frame
        self.backView.addSubview(blur)
    }
    
    func setupLabels() {
        self.topLabel.text = NSLocalizedString("Label.CreateStoryPopupTop", comment: String())
        self.ambientButton.setTitle(NSLocalizedString("Button.Ambient", comment: String()), forState: UIControlState.Normal)
        self.photoVideoButton.setTitle(NSLocalizedString("Button.PhotoVideo", comment: String()), forState: UIControlState.Normal)
        self.textButton.setTitle(NSLocalizedString("Button.Text", comment: String()), forState: UIControlState.Normal)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Actions
    @IBAction func ambientTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { [weak self] () -> Void in
            self?.delegate?.ambientDidTapped?()
        }
    }
    
    @IBAction func photoVideoTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { [weak self] () -> Void in
            self?.delegate?.photoVideoDidTapped?()
        }
    }
    
    @IBAction func textTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { [weak self] () -> Void in
            self?.delegate?.textDidTapped?()
        }
    }
}

@objc protocol StoryPointCreationPopupDelegate {
    optional func ambientDidTapped()
    optional func photoVideoDidTapped()
    optional func textDidTapped()
}