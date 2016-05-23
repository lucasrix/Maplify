//
//  InfinitePageControl.swift
//  Maplify
//
//  Created by Sergei on 19/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kCellHorizontalMargin: CGFloat = 17

enum InfiniteScrollDirection {
    case None
    case Left
    case Right
}

protocol InfinitePageControlDelegate {
    func numberOfItems() -> Int
    func didShowPageView(pageControl: InfinitePageControl, view: UIView, index: Int)
}

class InfinitePageControl: UIScrollView, UIScrollViewDelegate {
    private var contentViews = [UIView]()
    private var currentPageIndex: Int = 0
    private var lastContentOffset: CGFloat = 0
    var pageControlDelegate: InfinitePageControlDelegate! = nil
    var cellModeEnabled: Bool = false
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: - setup
    private func setup() {
        self.delegate = self
//        self.pagingEnabled = true
//        self.clipsToBounds = false
    }
    
    // MARK: - actions
    func moveAndShowCell(index: Int, animated: Bool) {
        self.setupViewsAtIndex(index)
        self.scrollToPage(index, animated: animated)
    }
    
    func updateViewFrames() {
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
    
    // MARK: - private
    private func setupViewsAtIndex(index: Int) {
        self.contentViews.forEach({$0.removeFromSuperview()})
        self.contentViews.removeAll()
        
        let leftView = UIView()
        let centerView = UIView()
        let rightView = UIView()

        let viewWidth = CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin
        let viewHeight = CGRectGetHeight(self.frame)
        
        let lMargin = kCellHorizontalMargin * 0.5 * CGFloat(index - 1)
        let cMargin = kCellHorizontalMargin * 0.5 * CGFloat(index)
        let rMargin = kCellHorizontalMargin * 0.5 * CGFloat(index + 1)
        
        leftView.frame = CGRectMake(viewWidth * CGFloat(index - 1) + lMargin, 0, viewWidth, viewHeight)
        centerView.frame = CGRectMake(viewWidth * CGFloat(index) + cMargin, 0, viewWidth, viewHeight)
        rightView.frame = CGRectMake(viewWidth * CGFloat(index + 1) + rMargin, 0, viewWidth, viewHeight)
        
        self.pageControlDelegate?.didShowPageView(self, view: leftView, index: index - 1)
        self.pageControlDelegate?.didShowPageView(self, view: centerView, index: index)
        self.pageControlDelegate?.didShowPageView(self, view: rightView, index: index + 1)

        self.addSubview(leftView)
        self.addSubview(centerView)
        self.addSubview(rightView)
        
        self.contentViews = [leftView, centerView, rightView]
        
        self.currentPageIndex = index
        
        self.updateContentSize()
    }
    
    private func replaceViewsWithDirection(direction: InfiniteScrollDirection, index: Int) {
        let viewWidth = CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin
        
        var viewToMove: UIView
        var viewIndex: Int
        
        var margin: CGFloat = 0
        
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
        
        margin = kCellHorizontalMargin * 0.5 * CGFloat(viewIndex)

        var frame = viewToMove.frame
        frame.origin.x = viewWidth * CGFloat(viewIndex) + margin
        frame.origin.y = 0
        viewToMove.frame = frame
        
        self.pageControlDelegate?.didShowPageView(self, view: viewToMove, index: index)
    }
    
    private func updateContentSize() {
        let viewWidth = CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin
        let margin = CGFloat((self.pageControlDelegate?.numberOfItems())!) * 0.5 * kCellHorizontalMargin
        self.contentSize = CGSizeMake(viewWidth * CGFloat((self.pageControlDelegate?.numberOfItems())!) + margin, 0)
    }
    
    private func scrollingGestureDirection(currentOffset: CGFloat, previousOffset: CGFloat) -> InfiniteScrollDirection {
        var scrollDirection: InfiniteScrollDirection = .None
      
        if previousOffset > currentOffset {
            scrollDirection = .Right
        } else if previousOffset < currentOffset {
            scrollDirection = .Left
        }
        
        return scrollDirection;
    }
    
    private func scrollToPage(index: Int, animated: Bool) {
        
        let margin = CGFloat(index - 2) * 0.5 * kCellHorizontalMargin
        let viewWidth = CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin
        let contentOffset = CGPointMake(viewWidth * CGFloat(index) + margin, 0)
        self.setContentOffset(contentOffset, animated: animated)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let viewWidth = CGRectGetWidth(self.frame)
        
        let direction = self.scrollingGestureDirection(self.contentOffset.x, previousOffset: self.lastContentOffset)
        
        var viewsShouldBeReplaced = false
        
        if (direction == .Left) {
            if (self.currentPageIndex < (self.pageControlDelegate?.numberOfItems())! - 1) {
                if ((scrollView.contentOffset.x / viewWidth) > CGFloat(self.currentPageIndex) + 0.5) {
                    self.currentPageIndex += 1
                    viewsShouldBeReplaced = true
                }
            }
        } else if (direction == .Right) {
            if (self.currentPageIndex > 0) {
                if ((scrollView.contentOffset.x / viewWidth) < CGFloat(self.currentPageIndex) - 0.5) {
                    self.currentPageIndex -= 1
                    viewsShouldBeReplaced = true
                }
            }
        }
        
        if viewsShouldBeReplaced {
            self.replaceViewsWithDirection(direction, index: self.currentPageIndex)
            self.lastContentOffset = self.contentOffset.x;
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let viewWidth = CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin
        let viewSpacing = kCellHorizontalMargin * 0.5

        let targetX = scrollView.contentOffset.x + velocity.x * 60.0
        
        var targetIndex: CGFloat = 0
        
        if (velocity.x > 0) {
            targetIndex = ceil(targetX / (viewWidth + viewSpacing))
        } else {
            targetIndex = floor(targetX / (viewWidth + viewSpacing))
        }
        
        targetContentOffset.memory.x = targetIndex * (viewWidth + viewSpacing) - kCellHorizontalMargin
    }
}

private extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {
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
