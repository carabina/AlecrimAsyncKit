//
//  AsyncAwait.swift
//  AlecrimAsyncKit
//
//  Created by Vanderlei Martinelli on 2015-05-10.
//  Copyright (c) 2015 Alecrim. All rights reserved.
//

import Foundation

private let _defaultTaskQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.name = "com.alecrim.AlecrimAsyncKit.Task"
    queue.qualityOfService = .Default
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
    
    return queue
    }()

private let _defaultRunTaskQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.name = "com.alecrim.AlecrimAsyncKit.RunTask"
    queue.qualityOfService = .Default
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount

    return queue
    }()

private let _defaultRunTaskCompletionQueue: NSOperationQueue = NSOperationQueue.mainQueue()


// MARK: - async

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, closure: (Task<V>) -> Void) -> Task<V> {
    return Task<V>(queue: queue, observers: nil, conditions: nil, closure: closure)
}

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, condition: TaskCondition, closure: (Task<V>) -> Void) -> Task<V> {
    return Task<V>(queue: queue, observers: nil, conditions: [condition], closure: closure)
}

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, conditions: [TaskCondition], closure: (Task<V>) -> Void) -> Task<V> {
    return Task<V>(queue: queue, observers: nil, conditions: conditions, closure: closure)
}

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, observers: [TaskObserver<V>], closure: (Task<V>) -> Void) -> Task<V> {
    return Task<V>(queue: queue, observers: observers, conditions: nil, closure: closure)
}

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, conditions: [TaskCondition], observers: [TaskObserver<V>], closure: (Task<V>) -> Void) -> Task<V> {
    return Task<V>(queue: queue, observers: observers, conditions: conditions, closure: closure)
}

// MARK: - async - non failable task

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, closure: (NonFailableTask<V>) -> Void) -> NonFailableTask<V> {
    return NonFailableTask<V>(queue: queue, observers: nil, closure: closure)
}

@warn_unused_result
public func async<V>(queue: NSOperationQueue = _defaultTaskQueue, observers: [TaskObserver<V>], closure: (NonFailableTask<V>) -> Void) -> NonFailableTask<V> {
    return NonFailableTask<V>(queue: queue, observers: observers, closure: closure)
}


// MARK: - await

public func await<V>(@noescape closure: () -> Task<V>) throws -> V {
    return try closure().waitForCompletionAndReturnValue()
}

public func await<V>(task: Task<V>) throws -> V {
    return try task.waitForCompletionAndReturnValue()
}

public func runTask<V>(task: Task<V>, queue: NSOperationQueue = _defaultRunTaskQueue, completionQueue: NSOperationQueue = _defaultRunTaskCompletionQueue, completion completionHandler: ((V!, ErrorType?) -> Void)? = nil) {
    queue.addOperationWithBlock {
        do {
            let value = try task.waitForCompletionAndReturnValue()
            
            if let completionHandler = completionHandler {
                completionQueue.addOperationWithBlock {
                    completionHandler(value, nil)
                }
            }
        }
        catch let error {
            if let completionHandler = completionHandler {
                completionQueue.addOperationWithBlock {
                    completionHandler(nil, error)
                }
            }
        }
    }
}


// MARK: - await - non failable task

public func await<V>(@noescape closure: () -> NonFailableTask<V>) -> V {
    return closure().waitForCompletionAndReturnValue()
}

public func await<V>(task: NonFailableTask<V>) -> V {
    return task.waitForCompletionAndReturnValue()
}

public func runTask<V>(task: NonFailableTask<V>, queue: NSOperationQueue = _defaultRunTaskQueue, completionQueue: NSOperationQueue = _defaultRunTaskCompletionQueue, completion completionHandler: ((V) -> Void)? = nil) {
    queue.addOperationWithBlock {
        let value = task.waitForCompletionAndReturnValue()

        if let completionHandler = completionHandler {
            completionQueue.addOperationWithBlock {
                completionHandler(value)
            }
        }
    }
}
