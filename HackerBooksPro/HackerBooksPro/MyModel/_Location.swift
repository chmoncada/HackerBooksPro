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

public class _Location: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Location"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Location.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var latitude: NSNumber?

    @NSManaged public
    var longitude: NSNumber?

    // MARK: - Relationships

    @NSManaged public
    var annotation: Annotation

}

