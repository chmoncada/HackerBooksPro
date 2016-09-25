//
//  AppDelegate.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // iCloud Setup
        iCloudSetup()
        
        // App appearance
        customizeAppearance()
        
        // Load JSON if needed
        importJSONDataIfNeeded(coreDataStack)
        
        // put "recent" tags in the model each time the app start
        populateRecentTag()
        
        // Setup of initial views
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! LibraryViewController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! BookViewController
        
        // propagation of de coredatastack
        masterViewController.coreDataStack = coreDataStack
        detailViewController.coreDataStack = coreDataStack
        
        // delegate set
        masterViewController.delegate = detailViewController
        
        // tweak to ipad portrait mode
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
       
        // Save in iCLoud
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
       
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        // to run the closure of the backgorund download task
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }

}

// MARK: - iCloud
extension AppDelegate {
    
    func iCloudSetup() {
        // iCloud Settings
        let urlForCloud = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        
        if urlForCloud == nil {
            print("No iCloud")
        } else {
            
            let store = NSUbiquitousKeyValueStore.defaultStore()
            // Set an observer if the iCloud value changes in another device
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.iCloudKeysChanged(_:)), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
            
            store.synchronize()
            
        }
        
    }
    
    func iCloudKeysChanged(sender: NSNotification) {
        
        // Update local store values
        print("func: iCloudKeysChanged: VALOR CAMBIO")
        // FALTA
        
    }
}

// MARK: - Utils
extension AppDelegate {
    
    func populateRecentTag() {
        
        // As first step, "reset" all the "recent" tags, erase them from the model
        let tagString = "recent"
        Tag.eraseTag(tagString, context: coreDataStack.context)
        
        // check if each book should have the "recent" tag if it was open in the last 7 days
        let today = NSDate()
        let fetchRequest = NSFetchRequest(entityName: Book.entityName())
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Book]

            for book in results {
                if let date = book.pdf.lastTimeOpened {
                    // Check if the book was open in the last 7days
                    if daysBetweenDates(date, endDate: today) < 7 {
                        // Add "recent" tag
                        let newTag = Tag.uniqueTag("recent", context: coreDataStack.context)
                        let bookTag = BookTag(managedObjectContext: coreDataStack.context)
                        bookTag!.name = "\(book.title) - Recent"
                        bookTag!.tag = newTag!
                        bookTag!.book = book
                    }
                }
            }
            // Save context
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return
        }
    }

}
