//
//  Date-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 29/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

// MARK: - Date Utils

/**
 **Returns** an `Integer` with the days between `startDate` and `endDate`.
 - parameters:
 - startDate: Initial Date.
 - endDate: Final Date.
 */
func daysBetweenDates(_ startDate: Date, endDate: Date) -> Int {
    
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
    
    return components.day!
    
}
