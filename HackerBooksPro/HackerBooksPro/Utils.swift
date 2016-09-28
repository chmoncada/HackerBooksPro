//
//  Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

let tintColor = UIColor.black
let backButtonColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)

// MARK: - Load Utils
func loadImage(remoteURL url: URL, completion: @escaping (_ data: Data?) -> ())  {
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (error != nil) {
            DispatchQueue.main.async(execute: {() in
                completion(nil)
            })
            return
        }
        if let data = data {
            //imageView = UIImage(data: data)
            DispatchQueue.main.async(execute: {() in
                completion(data)
            })
            return
        }
        
    })
    
    downloadTask.resume()
    
}

// MARK: - Date Utils

func daysBetweenDates(_ startDate: Date, endDate: Date) -> Int {
    
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
    
    return components.day!

}

//MARK: - Color Customization

func customizeAppearance() {
    
    // Status Bar Appearance
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    // Navigation Bar Appearance
    UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white]
    UINavigationBar.appearance().barTintColor = tintColor
    UINavigationBar.appearance().isTranslucent = false
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




