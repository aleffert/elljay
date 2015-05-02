//
//  CoreDataStack.swift
//  elljay
//
//  Created by Akiva Leffert on 2/16/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import CoreData
import UIKit

class CoreDataStack {
    let storeCoordinator : NSPersistentStoreCoordinator
    init(storePath : NSURL, modelName : String) {
        let modelPath = NSBundle.mainBundle().URLForResource("FeedModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: modelPath)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ]
        var error : NSError?
        let store = storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,configuration: nil, URL: storePath, options: options, error: &error)
        if store == nil {
            NSLog("Error adding CoreData Persistent Store: \(error?.localizedDescription)\n\(error?.userInfo)")
        }
    }
   
}
