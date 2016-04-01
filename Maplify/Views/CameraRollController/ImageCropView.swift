//
//  ImageCropView.swift
//  CameraRoll
//
//  Created by Evgeniy Antonoff on 3/29/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import UIKit

let kImageViewAlphaMin: CGFloat = 0
let kImageViewAlphaMax: CGFloat = 1
let kZoomScaleDefault: CGFloat = 1
let kZoomScaleMax: CGFloat = 2.0

class ImageCropView: UIScrollView, UIScrollViewDelegate {
    var imageView = UIImageView()
    var imageSize: CGSize?
    var image: UIImage! = nil {
        
        didSet {
            if image != nil {
                if !imageView.isDescendantOfView(self) {
                    self.imageView.alpha = kImageViewAlphaMax
                    self.addSubview(imageView)
                }
            } else {
                imageView.image = nil
                return
            }
            
            let imageSize = self.imageSize ?? image.size
            if imageSize.width < self.frame.width || imageSize.height < self.frame.height {
                
                // The width or height of the image is smaller than the frame size
                if imageSize.width > imageSize.height {
                    let ratio = self.frame.width / imageSize.width
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                } else {
                    let ratio = self.frame.height / imageSize.height
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.size.height)
                    )
                }
                imageView.center = self.center
            } else {
                if imageSize.width > imageSize.height {
                    let ratio = self.frame.height / imageSize.height
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.height)
                    )
                } else {
                    let ratio = self.frame.width / imageSize.width
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                }
                self.contentOffset = CGPoint(
                    x: imageView.center.x - self.center.x,
                    y: imageView.center.y - self.center.y
                )
            }
            self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
            imageView.image = image
            self.zoomScale = kZoomScaleDefault
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.backgroundColor = UIColor.blackColor()
        self.frame.size      = CGSizeZero
        self.clipsToBounds   = true
        self.imageView.alpha = kImageViewAlphaMin
        
        imageView.frame = CGRect(origin: CGPointZero, size: CGSizeZero)
        
        self.maximumZoomScale = kZoomScaleMax
        self.minimumZoomScale = kZoomScaleDefault
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bouncesZoom = true
        self.bounces = true
        
        self.delegate = self
    }
    
    func changeScrollable(isScrollable: Bool) {
        self.scrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate Protocol
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}