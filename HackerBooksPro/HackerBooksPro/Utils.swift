//
//  Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

let tintColor = UIColor.blackColor()
let backButtonColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)

// MARK: - Load Utils
func loadImage(remoteURL url: NSURL, completion: (data: NSData?) -> ())  {
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), {() in
                completion(data:  nil)
            })
            return
        }
        if let data = data {
            //imageView = UIImage(data: data)
            dispatch_async(dispatch_get_main_queue(), {() in
                completion(data:  data)
            })
            return
        }
        
    })
    
    downloadTask.resume()
    
}

// MARK: - Date Utils

func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int {
    
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
    
    return components.day

}

//MARK: - Color Customization

func customizeAppearance() {
    
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




