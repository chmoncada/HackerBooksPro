import Foundation
import CoreData

typealias BookTagArray = [BookTag]

@objc(BookTag)
open class BookTag: _BookTag {
	
    class func removeFavoriteTag(fromBook book: Book, inContext context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<BookTag>(entityName: BookTag.entityName())
        fetchRequest.predicate = NSPredicate(format: "name == %@", "\(book.title) - Favorite")
        
        do {
            let result = try context.fetch(fetchRequest)
            switch result.count {
            case 0:
                //print("No tiene tag Favorite")
                return
            default:
                let object = result.first!
                context.delete(object)
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return
        }
        
    }
    
    class func removeTag(_ tag: String, fromBook book: Book, inContext context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<BookTag>(entityName: BookTag.entityName())
        fetchRequest.predicate = NSPredicate(format: "name == %@", tag)
        
        do {
            let result = try context.fetch(fetchRequest)
            switch result.count {
            case 0:
                //print("No tiene tag Favorite")
                return
            default:
                let object = result.first!
                context.delete(object)
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return
        }
        
    }
    
    
}
