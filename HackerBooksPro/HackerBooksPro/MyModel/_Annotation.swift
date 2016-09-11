// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Annotation.swift instead.

import Foundation
import CoreData

public enum AnnotationAttributes: String {
    case creationDate = "creationDate"
    case linkedPage = "linkedPage"
    case modificationDate = "modificationDate"
    case text = "text"
    case title = "title"
}

public enum AnnotationRelationships: String {
    case bookPdf = "bookPdf"
    case location = "location"
    case photo = "photo"
}

public class _Annotation: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Annotation"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Annotation.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var creationDate: NSDate

    @NSManaged public
    var linkedPage: NSNumber?

    @NSManaged public
    var modificationDate: NSDate

    @NSManaged public
    var text: String

    @NSManaged public
    var title: String

    // MARK: - Relationships

    @NSManaged public
    var bookPdf: BookPDF

    @NSManaged public
    var location: Location?

    @NSManaged public
    var photo: Photo?

}

