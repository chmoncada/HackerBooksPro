//
//  NSUserDefaults-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 07/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

let def = UserDefaults.standard

func saveBookInUserDefaults(_ book: Book) {
    
    // Obtain the NSData
    if let data = archiveURIRepresentation(book) {
        // save in userdefaults
        def.set(data, forKey: "lastbookopen")
    }
}

func archiveURIRepresentation(_ book: Book) -> Data? {
    let uri = book.objectID.uriRepresentation()
    return NSKeyedArchiver.archivedData(withRootObject: uri)
    
}
