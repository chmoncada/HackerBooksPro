// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Location.swift instead.

import Foundation
import CoreData

public enum LocationAttributes: String {
    case latitude = "latitude"
    case longitude = "longitude"
}

public enum LocationRelationships: String {
    case annotation = "annotation"
}

open class _Location: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Location"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Location.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var latitude: NSNumber?

    @NSManaged open
    var longitude: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var annotation: Annotation

}

