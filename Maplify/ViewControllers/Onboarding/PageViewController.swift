//
//  OnboardViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kTopPaddingIPhone4_0: CGFloat = 100
let kTitleTopPaddingIPhone4_0: CGFloat = 30
let kDescriptionLeftRightPaddingIPhone4_0: CGFloat = 30
let kDescriptionLabelFontSizeIPhone5_5: CGFloat = 21
let kPageIndicatorColorAlpha: CGFloat = 0.5
let kPageControlBottomPaddingIPhone4_0: CGFloat = 70
let kPageControlBottomPaddingIPhone4_7: CGFloat = 115
let kPageControlBottomPaddingIPhone5_5: CGFloat = 150

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let pageContentViewControllers = [
        UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.onboardDiscoverController),
        UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier(Controllers.onboardCaptureController)
    ]
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.setupPageControl(subView as! UIPageControl)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - setup
    func setup() {
        self.setupPageController()
    }
    
    func setupPageController() {
        self.dataSource = self
        self.setViewControllers([pageContentViewControllers.first!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func setupPageControl(pageControl: UIPageControl) {
        if UIScreen().isIPhoneScreenSize4_0() {
            pageControl.frame.origin.y -= kPageControlBottomPaddingIPhone4_0
        } else if UIScreen().isIPhoneScreenSize4_7() {
            pageControl.frame.origin.y -= kPageControlBottomPaddingIPhone4_7
        } else {
            pageControl.frame.origin.y -= kPageControlBottomPaddingIPhone5_5
        }
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(kPageIndicatorColorAlpha)
        pageControl.currentPageIndicatorTintColor = UIColor.dodgerBlue()
        self.view.bringSubviewToFront(pageControl)
    }
    
    // MARK: - UIPageViewControllerDataSource
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageContentViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = self.pageContentViewControllers.indexOf(viewController)
        if index == nil || index! + 1 == pageContentViewControllers.count {
            return nil
        } else {
            return pageContentViewControllers[index! + 1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = self.pageContentViewControllers.indexOf(viewController)
        if index == nil || index! == 0 {
            return nil
        } else {
            return pageContentViewControllers[index! - 1]
        }
    }
}
