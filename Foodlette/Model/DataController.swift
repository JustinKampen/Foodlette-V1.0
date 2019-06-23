//
//  DataController.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    // -------------------------------------------------------------------------
    // MARK: - Data Controller Setup
    
    let persistentController: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentController.viewContext
    }
    
    init(modelName: String) {
        persistentController = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentController.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - Auto Save Functionality

extension DataController {
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
