import Foundation

let favStatusDidChange = "Favorite status did change"
let imageDidDownload = "Image did download"
let annotationsDidChange = "Annotations changed"
let pdfWasFinished = "Book finished"

@objc(Book)

public class Book: _Book {
    
    var pdfDownloaded: Bool? {
        if self.pdf.pdfData != nil {
            //print("valor del libro: \(self.title) es: TRUE")
            return true
        } else {
            //print("valor del libro: \(self.title) es: FALSE")
            return false
        }
    }
    
    var isChanged: Bool? {
        willSet {
            print("MODELO \(self.title) CAMBIO!!!")
            let notif = NSNotification(name: favStatusDidChange, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notif)
            
        }
    }
    
    var imageIsLoaded: Bool? {
        willSet {
            print("IMAGEN de \(self.title) SE DESCARGO!!!")
            let notif = NSNotification(name: imageDidDownload, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notif)
        }
    }
    
    var annotationsChanged: Bool? {
        willSet {
            print("Las anotaciones de \(self.title) cambiaron!!!")
            let notif = NSNotification(name: annotationsDidChange, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notif)
        }
    }
    
    var isFinished: Bool? {
        didSet {
            
            
            // Crear tag "Finished" y lanzar la notificacion para que la tabla se recargue?, con el fetched se supone que deberia recargarse sola
            if isFinished! {

                print("Libro \(self.title) Termino de leerse!!!")
                let newTag = Tag.uniqueTag("finished", context: self.managedObjectContext!)
                let bookTag = BookTag(managedObjectContext: self.managedObjectContext!)
                bookTag!.name = "\(self.title) - Finished"
                bookTag!.tag = newTag!
                bookTag!.book = self
                
                // Send notification
                let notif = NSNotification(name: pdfWasFinished, object: self)
                NSNotificationCenter.defaultCenter().postNotification(notif)
                
            } else {
                print("ya no estoy leido hasta el final")
            }
            
            
            
            
        }
    }
    
    // The implementation is easier because is a NSOrderedSet
    func authorsList() -> String {
        
        var text = ""
        
        for each in self.authors where each !== self.authors.lastObject{
            text += "\(each.name!), "
        }
        
        text += self.authors.lastObject!.name
        
        return text
    }

    // Method is different from authorList because bookTags is a NSSet
    func tagsList() -> String? {
        
        var arrayOfTags = [String]()
        if let array = self.bookTags.allObjects as? BookTagArray {
            // go through the array except the tags __FAVORITO
            for each in array where !(each.tag.tag == "__FAVORITO") {
                arrayOfTags.append(each.tag.tag)
            }
            arrayOfTags.sortInPlace()
            let list = arrayOfTags.joinWithSeparator(", ")
            
            return list
        }
        
        return nil
    }
    
    
}
