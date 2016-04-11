//
//  StoryDetailViewController.swift
//  Maplify
//
//  Created by - Jony - on 4/11/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit

class StoryDetailViewController: ViewController, UIPageViewControllerDataSource {
    var storyPoints: [StoryPoint]! = nil
    var selectedIndex: Int = 0
    var pageViewController: StoryPageViewController! = nil
    
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
    }
    
    func setupPageIndicator() {
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.backgroundColor = UIColor.grapePurple()
    }
    
    func setupPageController() {
        self.pageViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Controllers.storyPageViewController) as! StoryPageViewController
        self.pageViewController.dataSource = self
        
        let startViewController = self.getItemController(self.selectedIndex)
        self.pageViewController.setViewControllers([startViewController!] , direction: .Forward, animated: true, completion: nil)
        self.configureChildViewController(self.pageViewController, onView: self.view)
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.grapePurple()
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
        return self.selectedIndex
    }
}
