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

public class _Book: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Book"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Book.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var isFavorite: NSNumber?

    @NSManaged public
    var title: String

    // MARK: - Relationships

    @NSManaged public
    var authors: NSOrderedSet

    @NSManaged public
    var bookTags: NSSet

    @NSManaged public
    var image: BookImage

    @NSManaged public
    var pdf: BookPDF?

}

extension _Book {

    func addAuthors(objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthors(objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func addAuthorsObject(value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthorsObject(value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

}

extension _Book {

    func addBookTags(objects: NSSet) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.bookTags = mutable.copy() as! NSSet
    }

    func removeBookTags(objects: NSSet) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.bookTags = mutable.copy() as! NSSet
    }

    func addBookTagsObject(value: BookTag) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.bookTags = mutable.copy() as! NSSet
    }

    func removeBookTagsObject(value: BookTag) {
        let mutable = self.bookTags.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.bookTags = mutable.copy() as! NSSet
    }

}

