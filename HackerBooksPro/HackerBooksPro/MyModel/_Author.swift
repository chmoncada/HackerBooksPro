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

open class _Author: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Author"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Author.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String

    // MARK: - Relationships

    @NSManaged open
    var books: NSOrderedSet

}

extension _Author {

    func addBooks(_ objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooks(_ objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func addBooksObject(_ value: Book) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooksObject(_ value: Book) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

}

