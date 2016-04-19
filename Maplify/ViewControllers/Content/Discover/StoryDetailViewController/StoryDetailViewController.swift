//
//  StoryDetailViewController.swift
//  Maplify
//
//  Created by - Jony - on 4/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

let kPageIndicatorTintColorAlpha: CGFloat = 0.5

class StoryDetailViewController: ViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    var storyPoints: [StoryPoint]! = nil
    var selectedIndex: Int = 0
    var pageViewController: StoryPageViewController! = nil
    var storyTitle = String()
    
    @IBOutlet weak var cont: UIView!
    @IBOutlet weak var pageControlBackView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupNavigationBar()
        self.setupPageIndicator()
        self.setupPageController()
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // add shadow
        self.navigationController?.navigationBar.layer.shadowOpacity = kDiscoverNavigationBarShadowOpacity;
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeZero;
        self.navigationController?.navigationBar.layer.shadowRadius = kDiscoverNavigationBarShadowRadius;
        self.navigationController?.navigationBar.layer.masksToBounds = false;
        
        self.title = self.storyTitle
    }
    
    func setupPageIndicator() {
        self.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(kPageIndicatorTintColorAlpha)
        self.pageControl.backgroundColor = UIColor.clearColor()
        self.pageControl.numberOfPages = self.storyPoints.count
        self.pageControlBackView.layer.cornerRadius = self.pageControlBackView.frame.size.height / 2
    }
    
    
    override func viewDidLayoutSubviews() {
        for subView in self.pageViewController.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.setupPageControl(subView as! UIPageControl)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    func setupPageControl(pageControl: UIPageControl) {
        pageControl.frame.origin.y += 30
        pageControl.backgroundColor = UIColor.redColor()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(kPageIndicatorColorAlpha)
        pageControl.currentPageIndicatorTintColor = UIColor.dodgerBlue()
        self.view.bringSubviewToFront(pageControl)
    }
    
    func setupPageController() {
        self.pageViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPageViewController) as! StoryPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let startViewController = self.getItemController(self.selectedIndex)
        self.pageViewController.setViewControllers([startViewController!] , direction: .Forward, animated: true, completion: nil)
        self.configureChildViewController(self.pageViewController, onView: self.cont)
        
        for view in self.pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.grapePurple()
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! StoryDetailItemViewController
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! StoryDetailItemViewController
        if itemController.itemIndex + 1 < self.storyPoints.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> StoryDetailItemViewController? {
        self.pageControl.currentPage = itemIndex
        if itemIndex < self.storyPoints.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier(Controllers.storyDetailItemViewController) as! StoryDetailItemViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.storyPoint = self.storyPoints[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return storyPoints.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        self.pageControl.currentPage = self.selectedIndex
        return self.selectedIndex
    }
}
