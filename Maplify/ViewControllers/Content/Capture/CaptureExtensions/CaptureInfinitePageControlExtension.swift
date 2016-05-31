//
//  CaptureInfinitePageControlExtension.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager

extension CaptureViewController {
    
    // MARK: - InfinitePageControlDelegate
    func numberOfItems() -> Int {
        return (self.contentType == .StoryDetail) ? self.storyPointActiveModel.numberOfItems(0) + 1 : self.storyPointActiveModel.numberOfItems(0)
    }
    
    func didShowPageView(pageControl: InfiniteScrollView, view: UIView, index: Int) {
        var model = Model()
        
        if self.contentType == .StoryDetail {
            if index == 0 {
                model = self.storyToShow
            } else {
                model = self.storyPointActiveModel.cellData(NSIndexPath(forRow: index - 1, inSection: 0)).model as! Model
            }
        } else {
            model = self.storyPointActiveModel.cellData(NSIndexPath(forRow: index, inSection: 0)).model as! Model
        }
        
        if model is StoryPoint {
            DetailMapItemHelper.configureStoryPointView(view, storyPoint: model as! StoryPoint, delegate: self)
        } else if model is Story {
            DetailMapItemHelper.configureStoryView(view, story: model as! Story, delegate: self)
        }
    }
    
    func didScrollPageView(pageControl: InfiniteScrollView, index: Int) {
        var indexToSelect = index
        if self.contentType == .StoryDetail {
            if index > 0 {
                indexToSelect -= 1
                self.mapActiveModel.selectPinAtIndex(indexToSelect)
            }
        } else {
            self.mapActiveModel.selectPinAtIndex(indexToSelect)
        }
        self.mapDataSource.reloadMapView(StoryPointMapItem)
        
        if indexToSelect < self.storyPointActiveModel.numberOfItems(0) {
            let storyPoint = self.storyPointActiveModel.cellData(NSIndexPath(forRow: indexToSelect, inSection: 0)).model as! StoryPoint
            let location = CLLocationCoordinate2DMake(storyPoint.location.latitude , storyPoint.location.longitude)
            let pointInView = self.googleMapService.pointFromLocation(location)
            self.scrollToDestinationPointWithOffset(pointInView)
        }
    }
}
