import Foundation
import CoreData

@objc(Tag)
open class Tag: _Tag {
    
    
    // MARK: - Class Methods
    
    /// Returns a Tag object with tag String
    class func findTag(_ tag: String, context: NSManagedObjectContext) -> Tag? {
        
        let fetchRequest = NSFetchRequest<Tag>(entityName: self.entityName())
        
        fetchRequest.predicate = NSPredicate(format: "tag == %@", tag)
        
        do {
            let result = try context.fetch(fetchRequest) 
            
            switch result.count {
            case 0:
                return nil
            case 1:
                return result.first!
            default:
                print("no deberia haber mas de un objeto TAG")
                return result.first!
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Return a unique Tag object
    class func uniqueTag(_ tag: String, context: NSManagedObjectContext) -> Tag?{
        
        var result = Tag.findTag(tag, context: context)
        if result == nil {
            result = Tag(managedObjectContext: context)
        }
        result?.tag = tag
        
        if tag == "favorite" {
            result?.proxyForSorting = "___" + "favorite"
        } else if tag == "recent"{
            result?.proxyForSorting = "__" + "recent"
        } else if tag == "finished"{
            result?.proxyForSorting = "_" + "finished"
        } else {
            result?.proxyForSorting = tag
        }
        
        return result
        
    }
    
    class func eraseTag(_ tag: String, context:NSManagedObjectContext) {
        
        if let tagToErase = Tag.findTag(tag, context: context) {
            context.delete(tagToErase)
        } else {
            return
        }
    }
    
}
