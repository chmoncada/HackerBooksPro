//
//  JSONUtils.swift
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
func importJSONDataIfNeeded(coreDataStack:CoreDataStack) {
    
    // First we checked if exists any Book object in Core Data
    let fetchRequest = NSFetchRequest(entityName: Book.entityName())
    
    //var error: NSError? = nil

    do {
        let results =  try coreDataStack.context.countForFetchRequest(fetchRequest)
        
        if (results == 0) {
            
            print("Cargando modelo del JSON...")
            do {
                // Fist we erase any remaining object just in case
                let results =
                    try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Book]
                
                // Fist we erase any remaining object just in case
                for object in results {
                    let team = object as Book
                    coreDataStack.context.deleteObject(team)
                }
                
                //coreDataStack.saveContext()
                populateCoreDataModel(coreDataStack)
                
            } catch let error as NSError {
                print("Error fetching: \(error.localizedDescription)")
            }
        } else {
            //print("Se usara modelo existente")
        }

        
    } catch let error as NSError? {
        print("Error: \(error?.localizedDescription)")
    }
    
    //let results = coreDataStack.context.countForFetchRequest(fetchRequest)
    
}

//JSON Remote loading
func populateCoreDataModel(coredataStack: CoreDataStack) {
    
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
            
            let book = Book(entity: bookEntity!, insertIntoManagedObjectContext: coredataStack.context)
            book.isFavorite = false
            
            guard let title = json[JSONKeys.title.rawValue] as? String else {
                throw HackerBooksError.WrongJSONFormat
            }
            
            guard let imageURLString = json[JSONKeys.imageURL.rawValue] as? String else {
                throw HackerBooksError.WrongURLFormatForJSONResource
            }
            
            guard let pdfURLString = json[JSONKeys.pdfURL.rawValue] as? String else {
                    throw HackerBooksError.WrongURLFormatForJSONResource
            }
            
            book.title = title
            
            let image = BookImage(entity: bookImageEntity!, insertIntoManagedObjectContext: coredataStack.context)
            image.imageURL = imageURLString
            book.image = image
            
            let pdf = BookPDF(entity: bookPDFEntity!, insertIntoManagedObjectContext: coredataStack.context)
            pdf.pdfURL = pdfURLString
            book.pdf = pdf
            
            guard let authors = json[JSONKeys.authors.rawValue] as? String else{
                throw HackerBooksError.WrongJSONFormat
            }
            let authorsArray = authors.componentsSeparatedByString(", ").removeDuplicates().sort()
            let authorsSet : NSOrderedSet = NSOrderedSet(array: authorsArray)
            for each in authorsSet {
                let author = Author(entity: authorEntity!, insertIntoManagedObjectContext: coredataStack.context)
                author.name = each as! String
                book.addAuthorsObject(author)
            }
            
            guard let tags = json[JSONKeys.tags.rawValue] as? String else{
                throw HackerBooksError.WrongJSONFormat
            }
            let tagsArray = tags.componentsSeparatedByString(", ").removeDuplicates().sort()
            let tagsSet : NSOrderedSet = NSOrderedSet(array: tagsArray)
            for each in tagsSet {
                let bookTag = BookTag(entity: bookTagEntity!, insertIntoManagedObjectContext: coredataStack.context)
                let tagName = each as! String
                bookTag.name = "\(book.title) - \(tagName)"
                //let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: coredataStack.context)
                book.addBookTagsObject(bookTag)
                //tag.tag = (each as! String)
                
                let tag = Tag.uniqueTag(tagName, context: coredataStack.context)
                
                tag!.addBookTagsObject(bookTag)
                
            }

        }
        // Save the context
        //coredataStack.saveContext()
        print("Se termino de poblar el modelo de Core Data")
        
    } catch let error as NSError {
        print("Error populating Core Data model: \(error.localizedDescription)")
    }
    
}


func loadJSONFromRemoteFile() throws -> JSONArray{
    
    let inputURL = "https://t.co/K9ziV0z3SJ"
    
    if let url = NSURL(string: inputURL),
        let data = NSData(contentsOfURL: url),
        let maybeArray = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONArray,
        let array = maybeArray {
        return array
    } else {
        throw HackerBooksError.jsonParsingError
    }
}


