//
//  InfinitePageControl.swift
//  Maplify
//
//  Created by Sergei on 19/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kCellHorizontalMargin: CGFloat = 17
let kGlobalCellOffset: CGFloat = kCellHorizontalMargin * 0.5
let kSecondsInMinute: CGFloat = 60
let kDeleteAnimationDuration: NSTimeInterval = 0.2

enum InfiniteScrollDirection {
    case None
    case Left
    case Right
}

protocol InfiniteScrollViewDelegate {
    func numberOfItems() -> Int
    func didShowPageView(pageControl: InfiniteScrollView, view: UIView, index: Int)
    func didScrollPageView(pageControl: InfiniteScrollView, index: Int)
}

class InfiniteScrollView: UIScrollView, UIScrollViewDelegate {
    private var contentViews = [UIView]()
    private(set) internal var currentPageIndex: Int = 0
    private var lastContentOffset: CGFloat = 0
    
    var cellCornerRadius: CGFloat = 0
    var pageControlDelegate: InfiniteScrollViewDelegate! = nil
    var cellModeEnabled: Bool = false {
        didSet {
            self.pagingEnabled = !self.cellModeEnabled
        }
    }
    var yViewsOffset: CGFloat = 0
    
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
        self.pagingEnabled = true
    }
    
    // MARK: - actions
    func moveAndShowCell(index: Int, animated: Bool) {
        self.setupViewsAtIndex(index)
        self.scrollToPage(index, animated: animated)
    }
    
    // MARK: - private
    private func cellViewWidth() -> CGFloat {
        return self.cellModeEnabled ? CGRectGetWidth(self.frame) - 2 * kCellHorizontalMargin : CGRectGetWidth(self.frame)
    }
    
    private func setupViewsAtIndex(index: Int) {
        self.contentViews.forEach({$0.removeFromSuperview()})
        self.contentViews.removeAll()
        
        let leftView = UIView()
        let centerView = UIView()
        let rightView = UIView()
        
        leftView.hidden = true
        rightView.hidden = true
        
        if self.cellModeEnabled {
            leftView.layer.cornerRadius = self.cellCornerRadius
            centerView.layer.cornerRadius = self.cellCornerRadius
            rightView.layer.cornerRadius = self.cellCornerRadius
            
            leftView.layer.masksToBounds = true
            centerView.layer.masksToBounds = true
            rightView.layer.masksToBounds = true
        }
        
        leftView.backgroundColor = UIColor.whiteColor()
        centerView.backgroundColor = UIColor.whiteColor()
        rightView.backgroundColor = UIColor.whiteColor()
        
        let viewWidth = self.cellViewWidth()
        let viewHeight = CGRectGetHeight(self.frame)
        
        let leftMargin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(index - 1) + kCellHorizontalMargin : 0
        let centerMargin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(index) + kCellHorizontalMargin : 0
        let rightMargin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(index + 1) + kCellHorizontalMargin : 0
        
        leftView.frame = CGRectMake(viewWidth * CGFloat(index - 1) + leftMargin, yViewsOffset, viewWidth, viewHeight)
        centerView.frame = CGRectMake(viewWidth * CGFloat(index) + centerMargin, yViewsOffset, viewWidth, viewHeight)
        rightView.frame = CGRectMake(viewWidth * CGFloat(index + 1) + rightMargin, yViewsOffset, viewWidth, viewHeight)
        
        if (index - 1) >= 0 {
            self.pageControlDelegate?.didShowPageView(self, view: leftView, index: index - 1)
            leftView.hidden = false
        }
        
        self.pageControlDelegate?.didShowPageView(self, view: centerView, index: index)

        if (index + 1) < self.pageControlDelegate?.numberOfItems() {
            self.pageControlDelegate?.didShowPageView(self, view: rightView, index: index + 1)
            rightView.hidden = false
        }
        
        self.addSubview(leftView)
        self.addSubview(centerView)
        self.addSubview(rightView)
        
        self.contentViews = [leftView, centerView, rightView]
        
        self.currentPageIndex = index
        
        self.updateContentSize()
    }
    
    private func replaceViewsWithDirection(direction: InfiniteScrollDirection, index: Int) {
        self.contentViews.forEach({$0.hidden = false})
        
        let viewWidth = self.cellViewWidth()
        
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
        
        margin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(viewIndex) + kCellHorizontalMargin : 0
        
        if index == 0 {
            self.contentViews.first?.hidden = true
        }
        
        if index == (self.pageControlDelegate?.numberOfItems())! - 1 {
            self.contentViews.last?.hidden = true
        }
        
        var frame = viewToMove.frame
        frame.origin.x = viewWidth * CGFloat(viewIndex) + margin
        frame.origin.y = yViewsOffset
        viewToMove.frame = frame
        
        if (viewIndex >= 0 && viewIndex < (self.pageControlDelegate?.numberOfItems())!) {
            self.pageControlDelegate?.didShowPageView(self, view: viewToMove, index: viewIndex)
        }
    }
    
    private func updateContentSize() {
        let viewWidth = self.cellViewWidth()
        var margin: CGFloat = 0
        if self.cellModeEnabled {
            let additionalContentWidth = kGlobalCellOffset + kCellHorizontalMargin
            margin = CGFloat((self.pageControlDelegate?.numberOfItems())!) * kGlobalCellOffset + additionalContentWidth
        }
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
    
    func scrollToPage(index: Int, animated: Bool) {
        let margin = (self.cellModeEnabled) ? CGFloat(index - 1) * kGlobalCellOffset + kGlobalCellOffset : 0
        let viewWidth = self.cellViewWidth()
        let contentOffset = CGPointMake(viewWidth * CGFloat(index) + margin, 0)

        self.setContentOffset(contentOffset, animated: animated)
        self.lastContentOffset = self.contentOffset.x
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let viewWidth = CGRectGetWidth(self.frame)
        let direction = self.scrollingGestureDirection(self.contentOffset.x, previousOffset: self.lastContentOffset)
        
        var viewsShouldBeReplaced = false
        
        let offset = (self.cellModeEnabled) ? CGFloat(self.currentPageIndex) * (kCellHorizontalMargin + kGlobalCellOffset) - kCellHorizontalMargin : 0
        
        if (direction == .Left) {
            if (self.currentPageIndex < (self.pageControlDelegate?.numberOfItems())! - 1) {
                if (ceil((scrollView.contentOffset.x + offset) / viewWidth) > CGFloat(self.currentPageIndex)) {
                    self.currentPageIndex += 1
                    viewsShouldBeReplaced = true
                }
            }
        } else if (direction == .Right) {
            if (self.currentPageIndex > 0) {
                if (ceil((scrollView.contentOffset.x + offset - kCellHorizontalMargin) / viewWidth) < CGFloat(self.currentPageIndex)) {
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
        let viewWidth = self.cellViewWidth()
        var targetIndex: CGFloat = scrollView.contentOffset.x / scrollView.frame.size.width

        if self.cellModeEnabled {
            let targetX = scrollView.contentOffset.x + velocity.x * kSecondsInMinute
            
            if (velocity.x > 0) {
                targetIndex = ceil(targetX / (viewWidth + kGlobalCellOffset))
            } else {
                targetIndex = floor(targetX / (viewWidth + kGlobalCellOffset))
            }
            targetContentOffset.memory.x = targetIndex * (viewWidth + kGlobalCellOffset)
        }
   
        if (targetIndex >= 0 && targetIndex < CGFloat((self.pageControlDelegate?.numberOfItems())!)) {
            self.pageControlDelegate?.didScrollPageView(self, index: Int(targetIndex))
        }
    }
    
    func deleteCurrentView() {
        let centerView = self.contentViews[1]
        let rightView = self.contentViews.last!
        UIView.animateWithDuration(kDeleteAnimationDuration,
            animations: { [weak self] () in
                self?.updateViewsOrder()
                centerView.alpha = 0
                self?.moveRightViewToCenter(rightView)
            },
            completion: { [weak self] (finished) in
                self?.moveViewsToEmptySpace()
            })
    }
    
    func updateViewsOrder() {
        let rightView = self.contentViews.removeLast()
        self.contentViews.insert(rightView, atIndex: 1)
    }
    
    func moveCenterViewToRight(centerView: UIView) {
        let viewWidth = self.cellViewWidth()
        let margin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(self.currentPageIndex + 1) + kCellHorizontalMargin : 0
        var frame = centerView.frame
        frame.origin.x = viewWidth * CGFloat(self.currentPageIndex + 1) + margin
        frame.origin.y = self.yViewsOffset
        centerView.frame = frame
    }
    
    func moveRightViewToCenter(rightView: UIView) {
        let viewWidth = self.cellViewWidth()
        let margin = (self.cellModeEnabled) ? kGlobalCellOffset * CGFloat(self.currentPageIndex) + kCellHorizontalMargin : 0
        var frame = rightView.frame
        frame.origin.x = viewWidth * CGFloat(self.currentPageIndex) + margin
        frame.origin.y = self.yViewsOffset
        rightView.frame = frame
    }
    
    func moveViewsToEmptySpace() {
        let view = self.contentViews.last!
        self.moveCenterViewToRight(view)
        UIView.animateWithDuration(kDeleteAnimationDuration) {
            self.contentViews.forEach({$0.alpha = 1})
        }
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
