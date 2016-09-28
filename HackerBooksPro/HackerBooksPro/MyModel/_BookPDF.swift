// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BookPDF.swift instead.

import Foundation
import CoreData

public enum BookPDFAttributes: String {
    case isFinished = "isFinished"
    case lastPageOpen = "lastPageOpen"
    case lastTimeOpened = "lastTimeOpened"
    case pdfData = "pdfData"
    case pdfURL = "pdfURL"
}

public enum BookPDFRelationships: String {
    case annotations = "annotations"
    case book = "book"
}

open class _BookPDF: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "BookPDF"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _BookPDF.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var isFinished: NSNumber?

    @NSManaged open
    var lastPageOpen: NSNumber?

    @NSManaged open
    var lastTimeOpened: Date?

    @NSManaged open
    var pdfData: Data?

    @NSManaged open
    var pdfURL: String

    // MARK: - Relationships

    @NSManaged open
    var annotations: NSSet

    @NSManaged open
    var book: Book

}

extension _BookPDF {

    func addAnnotations(_ objects: NSSet) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.annotations = mutable.copy() as! NSSet
    }

    func removeAnnotations(_ objects: NSSet) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.annotations = mutable.copy() as! NSSet
    }

    func addAnnotationsObject(_ value: Annotation) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.annotations = mutable.copy() as! NSSet
    }

    func removeAnnotationsObject(_ value: Annotation) {
        let mutable = self.annotations.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.annotations = mutable.copy() as! NSSet
    }

}

