//
//  OnboardViewController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/18/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let pageIndicatorColorAlpha: CGFloat = 0.5

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let pageContentViewControllers = [
        UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier("onboardDiscoverController"),
        UIStoryboard.authStoryboard().instantiateViewControllerWithIdentifier("onboardCaptureController")
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
        var rect = pageControl.frame
        rect.origin.y -= 100
        pageControl.frame = rect
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(pageIndicatorColorAlpha)
        pageControl.currentPageIndicatorTintColor = UIColor.dodgerBlue()
        self.view.bringSubviewToFront(pageControl)
    }
    
    // MARK: - UIPageViewControllerDataSource
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageContentViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0;
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
