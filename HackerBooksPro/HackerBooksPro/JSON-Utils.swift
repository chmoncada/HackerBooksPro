//
//  JSON-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import CoreData

//MARK: Aliases

typealias JSONObject        = AnyObject
typealias JSONDictionary    = [String : JSONObject]
typealias JSONArray         = [JSONDictionary]

//MARK: - JSON Keys

enum JSONKeys: String {
    case title = "title"
    case authors = "authors"
    case tags = "tags"
    case imageURL = "image_url"
    case pdfURL = "pdf_url"
}

// MARK: JSON Utils

/**

 Check if the CoreData Model has data, otherwise load JSON data to the CoreData model

 - parameters:
    - coreDataStack: Instance of CoreDataStack of file
 
 */
func importJSONDataIfNeededUsingStack(_ coreDataStack:CoreDataStack) {
    
    // First we checked if exists any Book object in Core Data
    let fetchRequest = NSFetchRequest<Book>(entityName: Book.entityName())
    
    do {
        let results =  try coreDataStack.context.count(for: fetchRequest)
        
        if (results == 0) {
            
            do {
                // Fist we erase any remaining object just in case
                let results =
                    try coreDataStack.context.fetch(fetchRequest)
                
                for object in results {
                    let team = object as Book
                    coreDataStack.context.delete(team)
                }
                // Parse the JSON data to the model
                populateCoreDataModelUsingStack(coreDataStack)
                
            } catch let error as NSError {
                print("Error fetching: \(error.localizedDescription)")
            }
        }
    } catch let error as NSError? {
        print("Error: \(error?.localizedDescription)")
    }
    
}

//JSON Parsing

/**
 
 **Parse** JSON data to the model
 
 - parameters:
    - coredataStack: Instance of CoreDataStack of file
 
*/
func populateCoreDataModelUsingStack(_ coredataStack: CoreDataStack) {
    
    // Create Model Entities
    let authorEntity = Author.entity(coredataStack.context)
    let bookEntity = Book.entity(coredataStack.context)
    let bookImageEntity = BookImage.entity(coredataStack.context)
    let bookPDFEntity = BookPDF.entity(coredataStack.context)
    let bookTagEntity = BookTag.entity(coredataStack.context)
    //let tagEntity = Tag.entity(coredataStack.context)
    
    //Parse JSON file
    do {
        let jsonParsed = try loadJSONFromRemoteFile()
        
        for json in jsonParsed {
            
            let book = Book(entity: bookEntity!, insertInto: coredataStack.context)
            book.isFavorite = false
            
            guard let title = json[JSONKeys.title.rawValue] as? String else {
                throw HackerBooksError.wrongJSONFormat
            }
            
            guard let imageURLString = json[JSONKeys.imageURL.rawValue] as? String else {
                throw HackerBooksError.wrongURLFormatForJSONResource
            }
            
            guard let pdfURLString = json[JSONKeys.pdfURL.rawValue] as? String else {
                    throw HackerBooksError.wrongURLFormatForJSONResource
            }
            
            book.title = title
            
            let image = BookImage(entity: bookImageEntity!, insertInto: coredataStack.context)
            image.imageURL = imageURLString
            book.image = image
            
            let pdf = BookPDF(entity: bookPDFEntity!, insertInto: coredataStack.context)
            pdf.pdfURL = pdfURLString
            book.pdf = pdf
            
            guard let authors = json[JSONKeys.authors.rawValue] as? String else{
                throw HackerBooksError.wrongJSONFormat
            }
            let authorsArray = authors.components(separatedBy: ", ").removeDuplicates().sorted()
            let authorsSet : NSOrderedSet = NSOrderedSet(array: authorsArray)
            for each in authorsSet {
                let author = Author(entity: authorEntity!, insertInto: coredataStack.context)
                author.name = each as! String
                book.addAuthorsObject(author)
            }
            
            guard let tags = json[JSONKeys.tags.rawValue] as? String else{
                throw HackerBooksError.wrongJSONFormat
            }
            let tagsArray = tags.components(separatedBy: ", ").removeDuplicates().sorted()
            let tagsSet : NSOrderedSet = NSOrderedSet(array: tagsArray)
            for each in tagsSet {
                let bookTag = BookTag(entity: bookTagEntity!, insertInto: coredataStack.context)
                let tagName = each as! String
                bookTag.name = "\(book.title) - \(tagName)"
                book.addBookTagsObject(bookTag)
                
                let tag = Tag.uniqueTag(tagName, context: coredataStack.context)
                tag!.addBookTagsObject(bookTag)
                
            }
        }
        
    } catch let error as NSError {
        print("Error populating Core Data model: \(error.localizedDescription)")
    }
    
}

/**
 
 **Returns** a `JSONArray` ([JSONDictionary]) from a remote URL
 
 */
func loadJSONFromRemoteFile() throws -> JSONArray{
    
    // URL String of the remote JSON File
    let inputURL = "https://t.co/K9ziV0z3SJ"
    
    if let url = URL(string: inputURL),
        let data = try? Data(contentsOf: url),
        let maybeArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? JSONArray,
        let array = maybeArray {
        return array
    } else {
        throw HackerBooksError.jsonParsingError
    }
}


