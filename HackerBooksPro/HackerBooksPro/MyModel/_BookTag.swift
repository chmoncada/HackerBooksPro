// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BookTag.swift instead.

import Foundation
import CoreData

public enum BookTagAttributes: String {
    case name = "name"
}

public enum BookTagRelationships: String {
    case book = "book"
    case tag = "tag"
}

public class _BookTag: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "BookTag"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookTag.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var name: String?

    // MARK: - Relationships

    @NSManaged public
    var book: Book

    @NSManaged public
    var tag: Tag

}

