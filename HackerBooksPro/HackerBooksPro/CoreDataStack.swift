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
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.psc
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return managedObjectContext
    }()
    
    fileprivate lazy var psc: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName)
        
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType, configurationName: nil, at: url,
                options: options)
        } catch  {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main
            .url(forResource: self.modelName,
                            withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)
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
    
    func autoSave(_ delayInSeconds: TimeInterval) {
        if delayInSeconds > 0 {
            //print("Autosaving")
            saveContext()

            let delay = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: delay){
                self.autoSave(delayInSeconds)
            }
            
//            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
//            let time = Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC) + Double(DISPATCH_TIME_NOW)
            
            
        }
    }
    
}
