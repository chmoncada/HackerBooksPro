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
    let tintColor = UIColor.blackColor()
    let backButtonColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // MARK: App appearance
        customizeAppearance()
        
        
        importJSONDataIfNeeded(coreDataStack)
        
//        let navController = window!.rootViewController as! UINavigationController
//        let viewController = navController.topViewController as! LibraryViewController
//        viewController.coreDataStack = coreDataStack
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! LibraryViewController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! BookViewController
        
        masterViewController.coreDataStack = coreDataStack
        detailViewController.coreDataStack = coreDataStack
        
        
        
        //POR AHORA LE PASO UN BOOK INICIAL, DESPUES LO CAMBIARE POR EL QUE SE CARGUE DEL USER DEFAULTS
        let fetchRequest = NSFetchRequest(entityName: Book.entityName())
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Book]
            detailViewController.model = results.first
            
        } catch let error as NSError {
            print("ERROR \(error)")
        }
        // TODO ESTE BLOQUE DEBE CAMBIARSE POR EL DE NSUSER O EL DE ICLOUD
        
        
        masterViewController.delegate = detailViewController
        
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

    //MARK: - Color Customization
    
    private func customizeAppearance() {
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Navigation Bar Appearance
        UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.whiteColor()]
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().translucent = false
        // Back Button Appearance
        UINavigationBar.appearance().tintColor = backButtonColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:backButtonColor]
        // UITableViewHeader appearance
        UITableViewHeaderFooterView.appearance().tintColor = tintColor
        //UISearchBar.appearance().backgroundColor = tintColor
    }


}

