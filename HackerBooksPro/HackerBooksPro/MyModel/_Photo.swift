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

public class _Photo: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Photo"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Photo.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var photoData: NSData?

    // MARK: - Relationships

    @NSManaged public
    var annotation: NSSet

}

extension _Photo {

    func addAnnotation(objects: NSSet) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.annotation = mutable.copy() as! NSSet
    }

    func removeAnnotation(objects: NSSet) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.annotation = mutable.copy() as! NSSet
    }

    func addAnnotationObject(value: Annotation) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.annotation = mutable.copy() as! NSSet
    }

    func removeAnnotationObject(value: Annotation) {
        let mutable = self.annotation.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.annotation = mutable.copy() as! NSSet
    }

}

