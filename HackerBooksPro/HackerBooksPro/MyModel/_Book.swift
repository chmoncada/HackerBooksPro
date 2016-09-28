// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Book.swift instead.

import Foundation
import CoreData

public enum BookAttributes: String {
    case isFavorite = "isFavorite"
    case title = "title"
}

public enum BookRelationships: String {
    case authors = "authors"
    case bookTags = "bookTags"
    case image = "image"
    case pdf = "pdf"
}

open class _Book: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Book"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Book.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var isFavorite: NSNumber?

    @NSManaged open
    var title: String

    // MARK: - Relationships

    @NSManaged open
    var authors: NSOrderedSet

    @NSManaged open
    var bookTags: NSSet

    @NSManaged open
    var image: BookImage

    @NSManaged open
    var pdf: BookPDF

}

extension _Book {

    func addAuthors(_ objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthors(_ objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func addAuthorsObject(_ value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthorsObject(_ value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

}

extension _Book {

    func addBookTags(_ objects: NSSet) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.bookTags = mutable.copy() as! NSSet
    }

    func removeBookTags(_ objects: NSSet) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.bookTags = mutable.copy() as! NSSet
    }

    func addBookTagsObject(_ value: BookTag) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.bookTags = mutable.copy() as! NSSet
    }

    func removeBookTagsObject(_ value: BookTag) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.bookTags = mutable.copy() as! NSSet
    }

}

