// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BookPDF.swift instead.

import Foundation
import CoreData

public enum BookPDFAttributes: String {
    case pdfData = "pdfData"
    case pdfURL = "pdfURL"
}

public enum BookPDFRelationships: String {
    case book = "book"
}

public class _BookPDF: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "BookPDF"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookPDF.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var pdfData: NSData?

    @NSManaged public
    var pdfURL: String

    // MARK: - Relationships

    @NSManaged public
    var book: Book

}

