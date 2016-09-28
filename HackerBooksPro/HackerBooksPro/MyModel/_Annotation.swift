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

open class _Annotation: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Annotation"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Annotation.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var creationDate: Date

    @NSManaged open
    var linkedPage: NSNumber?

    @NSManaged open
    var modificationDate: Date

    @NSManaged open
    var text: String

    @NSManaged open
    var title: String

    // MARK: - Relationships

    @NSManaged open
    var bookPdf: BookPDF

    @NSManaged open
    var location: Location?

    @NSManaged open
    var photo: Photo?

}

