//
//  iCloud-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 30/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import CoreData

/**
 
 **Obtain** last open `Book` from iCloud
 
 - parameters:
    - context: `NSManagedObjectContext` to use to obtain the last open `Book`
 
 */
func loadBookFromiCloudOfContext(_ context: NSManagedObjectContext) -> Book? {
    let store = NSUbiquitousKeyValueStore.default()
    if let uriDefault = store.object(forKey: "lastbookopen") as? Data {
        return objectWithArchivedURIRepresentation(uriDefault, inContext: context)
    }
    
    return nil
}

/**
 
 **Save** last open `Book` in iCloud
 
 - parameters:
    - book: Book to save
 
 */
func saveBookIniCloud(_ book: Book) {
    
    // Set the iCloud store
    let store = NSUbiquitousKeyValueStore.default()
    // Obtain the NSData
    if let data = archiveURIRepresentationOfBook(book) {
        store.set(data, forKey: "lastbookopen")
    }
    
}
