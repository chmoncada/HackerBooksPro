import Foundation
import CoreData

@objc(Tag)
open class Tag: _Tag {
    
    
    // MARK: - Class Methods
    
    // funcion para buscar si en el modelo ya existe un Tag con el mismo nombre
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
    
    // funcion para anadir un objecto Tag con el parametro tag no repetido
    class func uniqueTag(_ tag: String, context: NSManagedObjectContext) -> Tag?{
        
        var result = Tag.findTag(tag, context: context)
        if result == nil {
            result = Tag(managedObjectContext: context)
        }
        result?.tag = tag
//        switch tag {
//        case "favorite":
//            result?.proxyForSorting = "__" + "favorite"
//        case "finished":
//            result?.proxyForSorting = "_" + "finished"
//        default:
//            result?.proxyForSorting = tag
//        }
        
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
            //print("Encontre Tag, procedere a borrarlo")
            context.delete(tagToErase)
        } else {
            //print("El Tag no existe")
            return
        }
    }
    
    
    
}
