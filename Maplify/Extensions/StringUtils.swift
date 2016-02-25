//
//  StringUtils.swift
//  table_classes
//
//  Created by Sergey on 2/23/16.
//  Copyright © 2016 Sergey. All rights reserved.
//

import UIKit

extension String {
    var length: Int {
        return self.characters.count
    }
    
    func size(font: UIFont, boundingRect: CGRect) -> CGSize {
        if self.length > 0 {
            let attributedText = NSAttributedString(string: self, attributes: [NSFontAttributeName : font])
            let rect = attributedText.boundingRectWithSize(CGSizeMake(boundingRect.size.width, CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
            return rect.size
        }
        return CGSizeZero
    }
    
    func substr(start: Int, end: Int) -> String {
        if (start < 0 || start > self.characters.count) {
            return ""
        } else if end < 0 || end > self.characters.count {
            return ""
        }
        let range = Range(start: self.startIndex.advancedBy(start), end: self.startIndex.advancedBy(end))
        return self.substringWithRange(range)
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    func toDate(format : String? = "yyyy-MM-dd") -> NSDate? {
        return self.toDate(format, dateTimeZone: NSTimeZone.defaultTimeZone())
    }
    
    func toDate(format : String? = "yyyy-MM-dd", dateTimeZone: NSTimeZone) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = dateTimeZone
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(self)
    }
}