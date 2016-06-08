//
//  ProgressHUD.swift
//  Maplify
//
//  Created by Sergey on 3/9/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import ALThreeCircleSpinner

let kOverlayViewKey = "ProgressOverlayView"
let kOverlaySpinner = "OverlaySpinner"
let kOverlaySpinnerSize: CGFloat = 44
let kOverlayViewAlpha: CGFloat = 0.5

class ProgressHUD {
    var overlayView: UIView! = nil
    var spinner: ALThreeCircleSpinner! = nil
    
    func showProgressHUD() {
        self.setupOverlayView()
        self.setupSpinner(self.overlayView)
    }
    
    func showProgressHUD(view: UIView) {
        self.setupSpinner(view)
        self.placeSpinner(view)
    }
    
    func setupOverlayView() {
        self.overlayView = UIView(frame: (UIApplication.sharedApplication().keyWindow?.bounds)!)
        self.overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(kOverlayViewAlpha)
        UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView)
    }
    
    func setupSpinner(view: UIView) {
        let x = (CGRectGetWidth(view.frame) - kOverlaySpinnerSize) / 2
        let y = (CGRectGetHeight(view.frame) - kOverlaySpinnerSize) / 2
        let spinnerFrame = CGRectMake(x, y, kOverlaySpinnerSize, kOverlaySpinnerSize)
        self.spinner = ALThreeCircleSpinner(frame: spinnerFrame)
        self.spinner.tintColor = UIColor.dodgerBlue()
        self.placeSpinner((UIApplication.sharedApplication().keyWindow)!)
    }
    
    func placeSpinner(view: UIView) {
        view.addSubview(self.spinner)
        view.bringSubviewToFront(self.spinner)
        self.spinner.startAnimating()
    }
    
    func hideProgressHUD() {
        self.spinner?.stopAnimating()
        self.spinner?.removeFromSuperview()
        self.overlayView?.removeFromSuperview()
    }
    
    func hideProgressHUD(view: UIView) {
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
    }
}