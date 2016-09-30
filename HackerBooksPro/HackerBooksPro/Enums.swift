//
//  Errors.swift
//  HackerBooks
//
//  Created by Charles Moncada on 27/06/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

//MARK: JSON Errors
enum HackerBooksError : Error{
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
}

enum PDFDocumentError: Error {
    case urlNotValid
    case badDocumentType
}
