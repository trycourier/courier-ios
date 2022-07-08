//
//  File.swift
//  
//
//  Created by Michael Miller on 7/8/22.
//

import Foundation

public class SimultaneousOperationsQueue {
    
    typealias CompleteClosure = () -> ()

    private let dispatchQueue: DispatchQueue
    private lazy var tasksCompletionQueue = DispatchQueue.main
    private let semaphore: DispatchSemaphore
    var whenCompleteAll: (()->())?
    private lazy var numberOfPendingActionsSemaphore = DispatchSemaphore(value: 1)
    private lazy var _numberOfPendingActions = 0

    var numberOfPendingTasks: Int {
        get {
            numberOfPendingActionsSemaphore.wait()
            defer { numberOfPendingActionsSemaphore.signal() }
            return _numberOfPendingActions
        }
        set(value) {
            numberOfPendingActionsSemaphore.wait()
            defer { numberOfPendingActionsSemaphore.signal() }
            _numberOfPendingActions = value
        }
    }

    init(numberOfSimultaneousActions: Int, dispatchQueueLabel: String) {
        dispatchQueue = DispatchQueue(label: dispatchQueueLabel)
        semaphore = DispatchSemaphore(value: numberOfSimultaneousActions)
    }

    func run(closure: ((@escaping CompleteClosure) -> Void)?) {
        numberOfPendingTasks += 1
        dispatchQueue.async { [weak self] in
            guard   let self = self,
                    let closure = closure else { return }
            self.semaphore.wait()
            closure {
                defer { self.semaphore.signal() }
                self.numberOfPendingTasks -= 1
                if self.numberOfPendingTasks == 0, let closure = self.whenCompleteAll {
                    self.tasksCompletionQueue.async { closure() }
                }
            }
        }
    }

    func run(closure: (() -> Void)?) {
        numberOfPendingTasks += 1
        dispatchQueue.async { [weak self] in
            guard   let self = self,
                    let closure = closure else { return }
            self.semaphore.wait(); defer { self.semaphore.signal() }
            closure()
            self.numberOfPendingTasks -= 1
            if self.numberOfPendingTasks == 0, let closure = self.whenCompleteAll {
                self.tasksCompletionQueue.async { closure() }
            }
        }
    }
}
