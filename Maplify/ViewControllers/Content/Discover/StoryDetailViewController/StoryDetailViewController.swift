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
    var pageViewController: PageDetailViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        print(self.storyPoints.count)
        self.setupPageCotroller()
    }
    
    func setupPageCotroller() {
        self.pageViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("PageDetailViewController") as! PageDetailViewController
        self.pageViewController.dataSource = self
//        self.configureChildViewController(self.pageViewController, onView: self.view)
        
        let startVC = self.viewControllerAtIndex(self.selectedIndex) as! StoryDetailItemViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as! [StoryDetailItemViewController], direction: .Forward, animated: true, completion: nil)
        
        self.configureChildViewController(self.pageViewController, onView: self.view)
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
        
        if itemController.itemIndex+1 < self.storyPoints.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> StoryDetailItemViewController? {
        
        if itemIndex < self.storyPoints.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("StoryDetailItemViewController") as! StoryDetailItemViewController
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
        return 0
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController {
        if ((self.storyPoints.count == 0) || (index >= self.storyPoints.count)) {
//            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StoryDetailItemViewController") as! StoryDetailItemViewController
        
        //    pageContentViewController.imageName = self.images[index]
        //    pageContentViewController.titleText = self.pageTitles[index]
        //    pageContentViewController.pageIndex = index
        return pageContentViewController
    }
}
