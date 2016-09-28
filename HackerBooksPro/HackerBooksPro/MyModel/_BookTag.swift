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

open class _BookTag: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "BookTag"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookTag.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var book: Book

    @NSManaged open
    var tag: Tag

}

