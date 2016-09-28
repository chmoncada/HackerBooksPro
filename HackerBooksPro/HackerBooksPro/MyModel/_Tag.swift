// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.swift instead.

import Foundation
import CoreData

public enum TagAttributes: String {
    case proxyForSorting = "proxyForSorting"
    case tag = "tag"
}

public enum TagRelationships: String {
    case bookTags = "bookTags"
}

open class _Tag: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Tag"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Tag.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var proxyForSorting: String

    @NSManaged open
    var tag: String

    // MARK: - Relationships

    @NSManaged open
    var bookTags: NSSet

}

extension _Tag {

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

