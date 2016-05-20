//
//  MapCaptureViewController.swift
//  Maplify
//
//  Created by Sergei on 19/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class MapCaptureViewController: ViewController, InfinitePageControlDelegate {
    @IBOutlet weak var pageControl: InfinitePageControl!
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }

    // MARK: - setup
    func setup() {
        self.pageControl.pageControlDelegate = self
        self.pageControl.moveAndShowCell(1, animated: false)
    }
    
    // MARL: - InfinitePageControlDelegate
    func numberOfItems() -> Int {
        return 10
    }
    
    func didShowPageView(pageControl: InfinitePageControl, view: UIView, index: Int) {
        print("index: \(index)")
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        view.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}