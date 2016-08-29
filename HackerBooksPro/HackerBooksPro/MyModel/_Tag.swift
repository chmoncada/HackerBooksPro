// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.swift instead.

import Foundation
import CoreData

public enum TagAttributes: String {
    case name = "name"
}

public enum TagRelationships: String {
    case book = "book"
}

public class _Tag: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Tag"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Tag.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var name: String?

    // MARK: - Relationships

    @NSManaged public
    var book: NSOrderedSet

}

extension _Tag {

    func addBook(objects: NSOrderedSet) {
        let mutable = self.book.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.book = mutable.copy() as! NSOrderedSet
    }

    func removeBook(objects: NSOrderedSet) {
        let mutable = self.book.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.book = mutable.copy() as! NSOrderedSet
    }

    func addBookObject(value: Book) {
        let mutable = self.book.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.book = mutable.copy() as! NSOrderedSet
    }

    func removeBookObject(value: Book) {
        let mutable = self.book.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.book = mutable.copy() as! NSOrderedSet
    }

}

