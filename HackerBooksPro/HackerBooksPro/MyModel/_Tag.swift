// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.swift instead.

import Foundation
import CoreData

public enum TagAttributes: String {
    case tag = "tag"
}

public enum TagRelationships: String {
    case bookTags = "bookTags"
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
    var tag: String

    // MARK: - Relationships

    @NSManaged public
    var bookTags: NSSet

}

extension _Tag {

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

