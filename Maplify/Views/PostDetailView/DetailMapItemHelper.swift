//
//  DetailMapItemHelper.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DetailMapItemHelper {
    class func configureStoryPointView(view: UIView, storyPoint: StoryPoint) {
        let contentView = NSBundle.mainBundle().loadNibNamed("StoryPointInfoView", owner: nil, options: nil).first as! StoryPointInfoView
        contentView.frame = view.bounds
        contentView.configure(storyPoint)
        
        view.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        contentView.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        view.layer.masksToBounds = true
        contentView.layer.masksToBounds = true
        
        view.addSubview(contentView)
    }
    
    class func configureStoryView(view: UIView, story: Story) {
        let contentView = NSBundle.mainBundle().loadNibNamed("StoryPointInfoView", owner: nil, options: nil).first as! StoryInfoView
        contentView.frame = view.bounds
        contentView.configure(story)
        
        view.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        contentView.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        view.layer.masksToBounds = true
        contentView.layer.masksToBounds = true
        
        view.addSubview(contentView)
    }
}