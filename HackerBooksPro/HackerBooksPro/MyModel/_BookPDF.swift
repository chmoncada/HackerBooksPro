// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BookPDF.swift instead.

import Foundation
import CoreData

public enum BookPDFAttributes: String {
    case isFinished = "isFinished"
    case lastPageOpen = "lastPageOpen"
    case pdfData = "pdfData"
    case pdfURL = "pdfURL"
}

public enum BookPDFRelationships: String {
    case annotations = "annotations"
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
    var isFinished: NSNumber?

    @NSManaged public
    var lastPageOpen: NSNumber?

    @NSManaged public
    var pdfData: NSData?

    @NSManaged public
    var pdfURL: String

    // MARK: - Relationships

    @NSManaged public
    var annotations: NSSet

    @NSManaged public
    var book: Book

}

extension _BookPDF {

    func addAnnotations(objects: NSSet) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.annotations = mutable.copy() as! NSSet
    }

    func removeAnnotations(objects: NSSet) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.annotations = mutable.copy() as! NSSet
    }

    func addAnnotationsObject(value: Annotation) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.annotations = mutable.copy() as! NSSet
    }

    func removeAnnotationsObject(value: Annotation) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.annotations = mutable.copy() as! NSSet
    }

}

