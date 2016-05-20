//
//  InfinitePageControl.swift
//  Maplify
//
//  Created by Sergei on 19/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

enum InfiniteScrollDirection {
    case None
    case Left
    case Right
}

protocol InfinitePageControlDelegate {
    func didShowPageView(pageControl: InfinitePageControl, view: UIView, index: Int)
}

class InfinitePageControl: UIScrollView, UIScrollViewDelegate {
    private var contentViews = [UIView]()
    private var currentPageIndex: Int = 0
    private var lastContentOffset: CGFloat = 0
    private var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var pageControlDelegate: InfinitePageControlDelegate! = nil
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    //MARK: - setup
    func setup() {
        self.delegate = self
        self.pagingEnabled = true
    }
    
    func moveAndShowCell(index: Int, animated: Bool) {
        self.setupViewsAtIndex(index)
        self.scrollToPage(index, animated: animated)
    }
    
    func setupViewsAtIndex(index: Int) {
        self.contentViews.forEach({$0.removeFromSuperview()})
        self.contentViews.removeAll()
        
        let leftView = UIView()
        let centerView = UIView()
        let rightView = UIView()

        let viewWidth = CGRectGetWidth(self.frame)
        let viewHeight = CGRectGetHeight(self.frame)
        
        leftView.frame = CGRectMake(viewWidth * CGFloat(index - 1), 0, viewWidth, viewHeight)
        centerView.frame = CGRectMake(viewWidth * CGFloat(index), 0, viewWidth, viewHeight)
        rightView.frame = CGRectMake(viewWidth * CGFloat(index + 1), 0, viewWidth, viewHeight)
        
        self.pageControlDelegate?.didShowPageView(self, view: leftView, index: index)
        self.pageControlDelegate?.didShowPageView(self, view: centerView, index: index)
        self.pageControlDelegate?.didShowPageView(self, view: rightView, index: index)

        self.addSubview(leftView)
        self.addSubview(centerView)
        self.addSubview(rightView)
        
        self.contentViews = [leftView, centerView, rightView]
        
        self.currentPageIndex = index
        
        self.updateContentSize()
    }
    
    func replaceViewsWithDirection(direction: InfiniteScrollDirection, index: Int) {
        let viewWidth = CGRectGetWidth(self.frame)
        
        var viewToMove: UIView
        var viewIndex: Int
        
        if (direction == .Right) {
            viewIndex = index - 1;
            
            viewToMove = self.contentViews.last!
            self.contentViews.removeObject(viewToMove)
            self.contentViews.insert(viewToMove, atIndex: 0)
        } else {
            viewIndex = index + 1;
            
            viewToMove = self.contentViews.first!
            self.contentViews.removeObject(viewToMove)
            self.contentViews.append(viewToMove)
        }
        
        var frame = viewToMove.frame
        frame.origin.x = viewWidth * CGFloat(viewIndex)
        frame.origin.y = 0
        viewToMove.frame = frame
        
        if (index > 0 && index < self.items.count - 1) {
            self.pageControlDelegate?.didShowPageView(self, view: viewToMove, index: index)
        }
    }
    
    func updateContentSize() {
        let viewWidth = CGRectGetWidth(self.frame)
        self.contentSize = CGSizeMake(viewWidth * CGFloat(self.items.count), 0)
    }
    
    func scrollingGestureDirection(currentOffset: CGFloat, previousOffset: CGFloat) -> InfiniteScrollDirection {
        var scrollDirection: InfiniteScrollDirection = .None
      
        if previousOffset > currentOffset {
            scrollDirection = .Right
        } else if previousOffset < currentOffset {
            scrollDirection = .Left
        }
        
        return scrollDirection;
    }
    
    func updateFramesForKeepsakes() {
        let viewWidth = CGRectGetWidth(self.frame)
        let viewHeight = CGRectGetHeight(self.frame)
        
        let leftFrame = CGRectMake(viewWidth * CGFloat(self.currentPageIndex - 1), 0, viewWidth, viewHeight);
        let centerFrame = CGRectMake(viewWidth * CGFloat(self.currentPageIndex), 0, viewWidth, viewHeight);
        let rightFrame = CGRectMake(viewWidth * CGFloat(self.currentPageIndex + 1), 0, viewWidth, viewHeight);
        
        self.contentViews[0].frame = leftFrame
        self.contentViews[1].frame = centerFrame
        self.contentViews[2].frame = rightFrame
        
        self.updateContentSize()
    }
    
    func scrollToPage(index: Int, animated: Bool) {
        let viewWidth = CGRectGetWidth(self.frame);
        let contentOffset = CGPointMake(viewWidth * CGFloat(index), 0);
        self.setContentOffset(contentOffset, animated: animated)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let keepsakeViewWidth = CGRectGetWidth(self.frame)
        
        let direction = self.scrollingGestureDirection(self.contentOffset.x, previousOffset: self.lastContentOffset)
        
        var isPageChanged = false
        
        if (direction == .Left) {
            if (self.currentPageIndex < self.items.count - 1) {
                if ((scrollView.contentOffset.x / keepsakeViewWidth) > CGFloat(self.currentPageIndex) + 0.5) {
                    self.currentPageIndex += 1
                    isPageChanged = true
                }
            }
        } else if (direction == .Right) {
            if (self.currentPageIndex > 0) {
                if ((scrollView.contentOffset.x / keepsakeViewWidth) < CGFloat(self.currentPageIndex) - 0.5) {
                    self.currentPageIndex -= 1
                    isPageChanged = true
                }
            }
        }
        
        if (isPageChanged) {
            self.replaceViewsWithDirection(direction, index: self.currentPageIndex)
            self.lastContentOffset = self.contentOffset.x;
        }
    }
}

private extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}
