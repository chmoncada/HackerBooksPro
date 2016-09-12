//
//  NSUserDefaults-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 07/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

let def = NSUserDefaults.standardUserDefaults()

func saveBookInUserDefaults(book: Book) {
    
    // Obtain the NSData
    if let data = archiveURIRepresentation(book) {
        // save in userdefaults
        def.setObject(data, forKey: "lastbookopen")
    }
}

func archiveURIRepresentation(book: Book) -> NSData? {
    let uri = book.objectID.URIRepresentation()
    return NSKeyedArchiver.archivedDataWithRootObject(uri)
    
}