//
//  URIRepresentation-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 29/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import CoreData

/**
 
 Returns Data from URI representation of a `Book`
 
 - parameters:
    - book: `Book` object to obtain URI data
 */
func archiveURIRepresentationOfBook(_ book: Book) -> Data? {
    let uri = book.objectID.uriRepresentation()
    return NSKeyedArchiver.archivedData(withRootObject: uri)
    
}


/**
 
 Returns Book from URI representation
 
 - parameters:
    - archivedURI: URI reprentation of `Book` object
    - context: `NSManagedObjectContext` instance to obtain the `Book` object
 */

func objectWithArchivedURIRepresentation(_ archivedURI: Data, inContext context: NSManagedObjectContext) -> Book? {
    
    if let uri: URL = NSKeyedUnarchiver.unarchiveObject(with: archivedURI) as? URL, let nid = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) {
        let book = context.object(with: nid) as! Book
        return book
    }
    
    return nil
}
