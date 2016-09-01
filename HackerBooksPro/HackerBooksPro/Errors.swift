//
//  Errors.swift
//  HackerBooks
//
//  Created by Charles Moncada on 27/06/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

//MARK: JSON Errors
enum HackerBooksError : ErrorType{
    case WrongURLFormatForJSONResource
    case ResourcePointedByURLNotReachable
    case jsonParsingError
    case WrongJSONFormat
    case nilJSONObject
}

enum PDFDocumentError: ErrorType {
    case UrlNotValid
    case BadDocumentType
}