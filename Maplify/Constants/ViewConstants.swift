//
//  ViewConstants.swift
//  Maplify
//
//  Created by Sergey on 3/4/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

struct CornerRadius {
    static let defaultRadius: CGFloat = 5
    static let detailViewBorderRadius: CGFloat = 8
}

struct Border {
    static let defaultBorderWidth: CGFloat = 1
}

struct Frame {
    static let doneButtonFrame = CGRectMake(0, 0, 62, 28)
    static let pullToRefreshFrame = CGRectMake(0, 0, 24, 24)
}

struct ScreenSize {
    static let iPhoneSixScreenPointsHeight: CGFloat = 667
}

struct NavigationBar {
    static let defaultOpacity: CGFloat = 0.8
    static let captureStoryMapOpacity: CGFloat = 0.7
    static let defaultHeight: CGFloat = 64
    static let defaultSearchBarOpacity: CGFloat = 0.97
    static let navigationBarAlphaMin: CGFloat = 0
}

struct SearchBar {
    static let defaultHeight: CGFloat = 45
}

struct Sizes {
    static let assetsTargetSizeDefault = CGSizeMake(UIScreen().screenWidthScaled(), UIScreen().screenWidthScaled())
}