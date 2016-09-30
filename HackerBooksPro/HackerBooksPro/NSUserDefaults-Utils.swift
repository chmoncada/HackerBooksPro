//
//  NSUserDefaults-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 07/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import CoreData

/**
 
 **Save** last open `Book` in UserDefaults
 
 - parameters:
    - book: Book to save
 
 */
func saveBookInUserDefaults(_ book: Book) {
    
    // Obtain the NSData
    if let data = archiveURIRepresentationOfBook(book) {
        // save in userdefaults
        UserDefaults.standard.set(data, forKey: "lastbookopen")
    }
    
}

/**
 
 **Obtain** last open `Book` from UserDefaults
 
 - parameters:
    - context: `NSManagedObjectContext` to use to obtain the last open `Book`
 
 */
func loadBookFromUserDefaultsInContext(_ context: NSManagedObjectContext) -> Book? {
    if let uriDefault = UserDefaults.standard.object(forKey: "lastbookopen") as? Data {
        return objectWithArchivedURIRepresentation(uriDefault, inContext: context)
    }
    
    return nil
}
