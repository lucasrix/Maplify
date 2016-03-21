//
//  StoryPointEditInfoViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/21/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryPointEditInfoViewController: ViewController {
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var placeOrLocationLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var placeOrLocationTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var isPartOfStoryLabel: UILabel!
    @IBOutlet weak var addToStoryButton: UIButton!
    
    var storyPointDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.setupViews()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.StoryPointEditDescription.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Post", comment: String()))
        
        self.captionLabel.text = NSLocalizedString("Label.Caption", comment: String())
        self.placeOrLocationLabel.text = NSLocalizedString("Label.PlaceOrLocation", comment: String())
        self.tagsLabel.text = NSLocalizedString("Label.Tags", comment: String())
        
        self.captionTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterBriefCaption", comment: String())
        self.placeOrLocationTextField.placeholder = NSLocalizedString("Text.Placeholder.EveryPostMustBeGeotagged", comment: String())
        self.tagsTextField.placeholder = NSLocalizedString("Text.Placeholder.EnterTag", comment: String())
        
        self.isPartOfStoryLabel.text = NSLocalizedString("Label.IsThisPartOfStory", comment: String())
        self.addToStoryButton.setTitle(NSLocalizedString("Button.AddToStory", comment: String()), forState: .Normal)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    @IBAction func addToStoryTapped(sender: UIButton) {
        // TODO:
    }
}
