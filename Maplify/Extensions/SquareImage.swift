//
//  SquareImage.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 3/30/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

extension UIImage {
    func cropToSquare() -> UIImage {
        let resizeByWidth: Bool = self.size.width < self.size.height
        var cropRect = CGRectZero
        if resizeByWidth {
            cropRect = CGRectMake(0.0, (self.size.height - self.size.width) / 2, self.size.width, self.size.width)
        } else {
            cropRect = CGRectMake((self.size.width - self.size.height) / 2, 0.0, self.size.height, self.size.height)
        }
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect)
        let resultImage = UIImage(CGImage: imageRef!)
        return resultImage
    }
}
