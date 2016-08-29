// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Book.swift instead.

import Foundation
import CoreData

public enum BookAttributes: String {
    case isFavorite = "isFavorite"
    case title = "title"
}

public enum BookRelationships: String {
    case authors = "authors"
    case image = "image"
    case pdf = "pdf"
    case tags = "tags"
}

public class _Book: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Book"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Book.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var isFavorite: NSNumber?

    @NSManaged public
    var title: String

    // MARK: - Relationships

    @NSManaged public
    var authors: NSOrderedSet

    @NSManaged public
    var image: BookImage

    @NSManaged public
    var pdf: BookPDF?

    @NSManaged public
    var tags: NSOrderedSet

}

extension _Book {

    func addAuthors(objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthors(objects: NSOrderedSet) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func addAuthorsObject(value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

    func removeAuthorsObject(value: Author) {
        let mutable = self.authors.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.authors = mutable.copy() as! NSOrderedSet
    }

}

extension _Book {

    func addTags(objects: NSOrderedSet) {
        let mutable = self.tags.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.tags = mutable.copy() as! NSOrderedSet
    }

    func removeTags(objects: NSOrderedSet) {
        let mutable = self.tags.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.tags = mutable.copy() as! NSOrderedSet
    }

    func addTagsObject(value: Tag) {
        let mutable = self.tags.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.tags = mutable.copy() as! NSOrderedSet
    }

    func removeTagsObject(value: Tag) {
        let mutable = self.tags.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.tags = mutable.copy() as! NSOrderedSet
    }

}

