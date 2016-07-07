//
//  OperationQueueManager.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 7/7/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

typealias SynchronousClosure = (operation: NetworkOperation) -> ()

let kMaxConcurrentOperationCount = 1

class OperationQueueManager {
    static let sharedInstance = OperationQueueManager()
    
    var queue: NSOperationQueue! = nil
    
    init() {
        self.setupManager()
    }
    
    // MARK: - setup
    private func setupManager() {
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = kMaxConcurrentOperationCount
    }
    
    func addOperation(operationClosure: SynchronousClosure) {
        let operation = NetworkOperation(performRequestClosure: operationClosure)
        queue.addOperation(operation)
    }
}

protocol OperationQueueDelegate {
    func allOperationsCompleted(completion: (success: Bool) -> ()!)
}
