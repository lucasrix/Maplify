//
//  EventSuspender.swift
//  Maplify
//
//  Created by Sergey on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

typealias eventClosure = () -> ()

class Suspender: NSObject {
    var timer: NSTimer! = nil
    var event: eventClosure! = nil
    
    func suspendEvent() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func executeEvent(interval: NSTimeInterval, event: eventClosure) {
        self.event = event
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(Suspender.update), userInfo: nil, repeats: false)
    }
    
    func update() {
        self.event()
    }
}