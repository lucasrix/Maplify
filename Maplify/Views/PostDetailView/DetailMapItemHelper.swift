//
//  DetailMapItemHelper.swift
//  Maplify
//
//  Created by Sergei on 23/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class DetailMapItemHelper {
    class func configureStoryPointView(view: UIView, storyPoint: StoryPoint, delegate: StoryPointInfoViewDelegate) {
        view.subviews.forEach({$0.removeFromSuperview()})
        
        weak var contentView = NSBundle.mainBundle().loadNibNamed(String(StoryPointInfoView), owner: nil, options: nil).first as? StoryPointInfoView
        contentView?.frame = view.bounds
        contentView?.configure(storyPoint, delegate: delegate)
        
        contentView?.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        contentView?.layer.masksToBounds = true
        
        view.addSubview(contentView!)
    }
    
    class func configureStoryView(view: UIView, story: Story, delegate: StoryInfoViewDelegate) {
        view.subviews.forEach({$0.removeFromSuperview()})
        
        weak var contentView = NSBundle.mainBundle().loadNibNamed(String(StoryInfoView), owner: nil, options: nil).first as? StoryInfoView
        contentView?.frame = view.bounds
        contentView?.configure(story, delegate: delegate)
        
        contentView?.layer.cornerRadius = CornerRadius.detailViewBorderRadius
        contentView?.layer.masksToBounds = true
        
        view.addSubview(contentView!)
    }
}