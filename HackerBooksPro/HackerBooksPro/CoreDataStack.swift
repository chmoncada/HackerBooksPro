//
//  CoreDataStack.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//
//  Boilerplate code with some adaptations from book "Core Data by Tutorial" - Aaron Douglas and others

import CoreData

class CoreDataStack {
    
    let modelName = "HackerBooksPro"
    
    lazy var context: NSManagedObjectContext = {
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.psc
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return managedObjectContext
    }()
    
    private lazy var psc: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName)
        
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStoreWithType(
                NSSQLiteStoreType, configuration: nil, URL: url,
                options: options)
        } catch  {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle()
            .URLForResource(self.modelName,
                            withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                //print("Hay cambios en el modelo, se grabo el CONTEXTO")
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
    func autoSave(delayInSeconds: NSTimeInterval) {
        if delayInSeconds > 0 {
            //print("Autosaving")
            saveContext()

            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            
            dispatch_after(delay, dispatch_get_main_queue()){
                self.autoSave(delayInSeconds)
            }
            
//            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
//            let time = Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC) + Double(DISPATCH_TIME_NOW)
            
            
        }
    }
    
}
