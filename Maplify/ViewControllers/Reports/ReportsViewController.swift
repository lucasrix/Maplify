//
//  ReportsViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/25/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

enum PostType: Int {
    case StoryPoint
    case Story
}

enum ReportKind: String {
    case Dislike = "dislike"
    case Spam = "spam"
    case Risk = "risk"
    case Unsuited = "unsuited"
}

class ReportsViewController: ViewController {
    @IBOutlet weak var dontLikeThisPostButton: UIButton!
    @IBOutlet weak var spamOrScamButton: UIButton!
    @IBOutlet weak var postPutsRiskButton: UIButton!
    @IBOutlet weak var postShouldBeRemovedButton: UIButton!
    
    var postId: Int = 0
    var postType: PostType = .StoryPoint
    var completionClosure: (() -> ())! = nil

    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupTitle()
        self.setupButtons()
    }
    
    func setupTitle() {
        self.title = NSLocalizedString("Controller.Reports", comment: String())
    }
    
    func setupButtons() {
        self.dontLikeThisPostButton.setTitle(NSLocalizedString("Button.ReportsDontLikeThisPost", comment: String()), forState: .Normal)
        self.spamOrScamButton.setTitle(NSLocalizedString("Button.ReportsSpamOrScam", comment: String()), forState: .Normal)
        self.postPutsRiskButton.setTitle(NSLocalizedString("Button.ReportsPutsRisk", comment: String()), forState: .Normal)
        self.postShouldBeRemovedButton.setTitle(NSLocalizedString("Button.ReportsPostShouldBeRemoved", comment: String()), forState: .Normal)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - actions
    @IBAction func dontLikeThisPostTapped(sender: UIButton) {
        self.reportPost(.Dislike)
    }
    
    @IBAction func spamOrScamTapped(sender: UIButton) {
        self.reportPost(.Spam)
    }
    
    @IBAction func postPutsRiskTapped(sender: UIButton) {
        self.reportPost(.Risk)
    }
    
    @IBAction func postShouldBeRemovedTapped(sender: UIButton) {
        self.reportPost(.Unsuited)
    }
    
    // MARK: - private
    private func reportPost(kind: ReportKind) {
        if self.postType == .StoryPoint {
            self.remoteReportStoryPoint(kind)
        } else if self.postType == .Story {
            self.remoteReportStory(kind)
        }
    }
    
    private func remoteReportStoryPoint(kind: ReportKind) {
        // TODO:
    }
    
    private func remoteReportStory(kind: ReportKind) {
        // TODO:
    }
}
