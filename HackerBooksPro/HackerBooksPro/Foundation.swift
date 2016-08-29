//
//  Foundation.swift
//  HackerBooks
//
//  Created by Charles Moncada on 28/06/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

// to declare a URL with a String
extension NSBundle{
    
    func URLForResource(name: String?) -> NSURL? {
        
        let components = name?.componentsSeparatedByString(".")
        let fileTitle =  components?.first
        let fileExtension = components?.last
        
        return URLForResource(fileTitle, withExtension: fileExtension)
        
    }
}

// To clean duplicates in array
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

