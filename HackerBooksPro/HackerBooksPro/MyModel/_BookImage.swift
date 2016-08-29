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

public class _BookImage: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "BookImage"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookImage.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var imageData: NSData?

    @NSManaged public
    var imageURL: String

    // MARK: - Relationships

    @NSManaged public
    var book: Book

}

