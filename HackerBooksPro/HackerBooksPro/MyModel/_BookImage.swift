// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BookImage.swift instead.

import Foundation
import CoreData

public enum BookImageAttributes: String {
    case imageData = "imageData"
    case imageURL = "imageURL"
}

public enum BookImageRelationships: String {
    case book = "book"
}

open class _BookImage: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "BookImage"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookImage.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var imageData: Data?

    @NSManaged open
    var imageURL: String

    // MARK: - Relationships

    @NSManaged open
    var book: Book

}

