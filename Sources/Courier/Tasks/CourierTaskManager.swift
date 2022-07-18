//
//  File.swift
//  
//
//  Created by Michael Miller on 7/18/22.
//

import Foundation

class CourierTaskManager {
    
    var onTasksCompleted: (() -> Void)?
    
    private(set) var isRunning = false
    
    public var tasks: [String : CourierTask] = [:]
    
    func add(task: CourierTask) {
        
        let id = UUID().uuidString
        
        tasks[id] = task
        
        task.onComplete = { [weak self] in
            
            print("Task completed")
            print(self?.tasks)
            
            self?.tasks.removeValue(forKey: id)
            print("Task removed")
            
            if (self?.tasks.isEmpty == true) {
                self?.onTasksCompleted?()
            }
            
        }
        
        task.start()
        
//        if (!isRunning) {
//            isRunning = true
//        }
        
    }
    
}
