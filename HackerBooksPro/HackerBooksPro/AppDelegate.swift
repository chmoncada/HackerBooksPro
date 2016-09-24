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
    
    let tintColor = UIColor.blackColor()
    let backButtonColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // iCloud Setup
        iCloudSetup()
        
        // App appearance
        customizeAppearance()
        
        // Load JSON if needed
        importJSONDataIfNeeded(coreDataStack)
        
        // Calculate the RECENT tag in the model
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Entre en background....grabo en iCloud")
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
       
        
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
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

    //MARK: - Color Customization
    
    private func customizeAppearance() {
        
        // Status Bar Appearance
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        // Navigation Bar Appearance
        UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.whiteColor()]
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().translucent = false
        // ToolBar Appearance
        UIToolbar.appearance().tintColor = backButtonColor
        UIToolbar.appearance().barTintColor = tintColor
        // Back Button Appearance
        UINavigationBar.appearance().tintColor = backButtonColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:backButtonColor]
        // UITableViewHeader appearance
        UITableViewHeaderFooterView.appearance().tintColor = tintColor
        // UITabBar appearance
        UITabBar.appearance().tintColor = backButtonColor
        UITabBar.appearance().barTintColor = tintColor
    
    }

    func iCloudSetup() {
        // iCloud Settings
        let urlForCloud = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        
        if urlForCloud == nil {
            print("No iCloud")
        } else {
            
            let store = NSUbiquitousKeyValueStore.defaultStore()
            
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

extension AppDelegate {
    
    func populateRecentTag() {
        
        // Busco si hay Tag Recents y los borro
        let tagString = "recent"
        Tag.eraseTag(tagString, context: coreDataStack.context)
        
        // Calculo si el book necesita el Tag Recent
        
        // se lo anado al libro
        
        // Grabo el modelo
        
    }

}
