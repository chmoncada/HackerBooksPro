// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.swift instead.

import Foundation
import CoreData

public enum PhotoAttributes: String {
    case photoData = "photoData"
}

public enum PhotoRelationships: String {
    case annotation = "annotation"
}

open class _Photo: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Photo"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Photo.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var photoData: Data?

    // MARK: - Relationships

    @NSManaged open
    var annotation: NSSet

}

extension _Photo {

    func addAnnotation(_ objects: NSSet) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.annotation = mutable.copy() as! NSSet
    }

    func removeAnnotation(_ objects: NSSet) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.annotation = mutable.copy() as! NSSet
    }

    func addAnnotationObject(_ value: Annotation) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.annotation = mutable.copy() as! NSSet
    }

    func removeAnnotationObject(_ value: Annotation) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.annotation = mutable.copy() as! NSSet
    }

}

