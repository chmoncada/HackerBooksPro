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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /// App appearance
        customizeAppearance()
        
        /// Load JSON if needed
        importJSONDataIfNeededUsingStack(coreDataStack)
        
        /// Put "recent" tags in the model each time the app start
        populateRecentTag()
        
        /// Setup of initial views
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! LibraryViewController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! BookViewController
        
        /// propagation of de coredatastack
        masterViewController.coreDataStack = coreDataStack
        detailViewController.coreDataStack = coreDataStack
        
        /// delegate set
        masterViewController.delegate = detailViewController
        
        /// tweak to ipad portrait mode
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        /// set a automatic context saving
        coreDataStack.autoSave(5.0)
        
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // to run the closure of the backgorund download task
        backgroundSessionCompletionHandler = completionHandler
    }

}

// MARK: - Utils
extension AppDelegate {
    
    /**
     Put "recent" Tag to the Books that were open in the last seven (7) days
    */
    func populateRecentTag() {
        
        
        // As first step, "reset" all the "recent" tags, erase them from the model
        let tagString = "recent"
        Tag.eraseTag(tagString, context: coreDataStack.context)
        
        // check if each book should have the "recent" tag if it was open in the last 7 days
        let today = Date()
        let fetchRequest = NSFetchRequest<Book>(entityName: Book.entityName())
        
        do {
            let results = try coreDataStack.context.fetch(fetchRequest) 

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
