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
        self.setupSpinner()
    }
    
    func setupOverlayView() {
        self.overlayView = UIView(frame: (UIApplication.sharedApplication().keyWindow?.bounds)!)
        self.overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(kOverlayViewAlpha)
        UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView)
    }
    
    func setupSpinner() {
        let x = (self.overlayView.frame.size.width - kOverlaySpinnerSize) / 2
        let y = (self.overlayView.frame.size.height - kOverlaySpinnerSize) / 2
        let spinnerFrame = CGRectMake(x, y, kOverlaySpinnerSize, kOverlaySpinnerSize)
        self.spinner = ALThreeCircleSpinner(frame: spinnerFrame)
        self.spinner.tintColor = UIColor.dodgerBlue()
        UIApplication.sharedApplication().keyWindow?.addSubview(self.spinner)
        
        self.spinner.startAnimating()
    }
    
    func hideProgressHUD() {
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
        self.overlayView.removeFromSuperview()
    }
}