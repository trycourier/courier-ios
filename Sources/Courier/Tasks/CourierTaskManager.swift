//
//  CourierTaskManager.swift
//  
//
//  Created by Michael Miller on 7/18/22.
//

import Foundation

class CourierTaskManager {
    
    var allTasksCompleted: (() -> Void)?
    
    private(set) var isRunning = false
    
    public var tasks: [String : CourierTask] = [:]
    
    func add(_ task: CourierTask) {
        
        // Create an id for the task
        let id = UUID().uuidString
        
        // Add task to manager
        tasks[id] = task
        
        // Handle completion of the task
        task.onComplete = { [weak self] in
            
            guard let self = self else { return }
            
            // Remove the task from the manager
            self.tasks.removeValue(forKey: id)
            
            // Call global completion callback
            if (self.tasks.isEmpty == true) {
                self.allTasksCompleted?()
            }
            
        }
        
        // Start the new task
        task.start()
        
    }
    
}
