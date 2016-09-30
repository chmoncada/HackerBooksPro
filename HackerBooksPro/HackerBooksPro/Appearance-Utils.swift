//
//  Appearance-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 29/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

/// Define App Colors
let tintColor = UIColor.black /// Color of backgrounds
let textColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00) /// Color of text in UI Elements


/// To modify the colors of the app change the 'tintColor' and 'BackButtonColor' constants
func customizeAppearance() {
    
    /// Status Bar Appearance
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    /// Navigation Bar Appearance
    UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white]
    UINavigationBar.appearance().barTintColor = tintColor
    UINavigationBar.appearance().isTranslucent = false
    /// ToolBar Appearance
    UIToolbar.appearance().tintColor = textColor
    UIToolbar.appearance().barTintColor = tintColor
    /// Back Button Appearance
    UINavigationBar.appearance().tintColor = textColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:textColor]
    /// UITableViewHeader appearance
    UITableViewHeaderFooterView.appearance().tintColor = tintColor
    /// UITabBar appearance
    UITabBar.appearance().tintColor = textColor
    UITabBar.appearance().barTintColor = tintColor
    
}
