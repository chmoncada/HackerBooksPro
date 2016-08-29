// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Author.swift instead.

import Foundation
import CoreData

public enum AuthorAttributes: String {
    case name = "name"
}

public enum AuthorRelationships: String {
    case books = "books"
}

public class _Author: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Author"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Author.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var name: String

    // MARK: - Relationships

    @NSManaged public
    var books: NSOrderedSet

}

extension _Author {

    func addBooks(objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooks(objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func addBooksObject(value: Book) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooksObject(value: Book) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

}

