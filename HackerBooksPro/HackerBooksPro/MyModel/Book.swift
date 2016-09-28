import Foundation

let modelDidChange = "Model did change"
let favStatusDidChange = "Favorite status did change"
let imageDidDownload = "Image did download"
let annotationsDidChange = "Annotations changed"
let pdfWasFinished = "Book finished"
let newPageOpened = "Change page in reader"

@objc(Book)

open class Book: _Book {
    
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
            //print("MODELO \(self.title) CAMBIO!!!")
            let notif = Notification(name: Notification.Name(rawValue: modelDidChange), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var favIsChanged: Bool? {
        willSet {
            //print("Status de Favorito del libro \(self.title) CAMBIO!!!")
            let notif = Notification(name: Notification.Name(rawValue: favStatusDidChange), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var pdfIsOpen: Bool? {
        didSet {
            //print("Abri el PDF de \(self.title) para leer")
            self.pdf.lastTimeOpened = Date()
            
            // si el tag reciente ya lo tiene
            if !self.containsTag("recent") {
                
                // Create and add "Recent tag"
                let newTag = Tag.uniqueTag("recent", context: self.managedObjectContext!)
                
                let bookTag = BookTag(managedObjectContext: self.managedObjectContext!)
                bookTag!.name = "\(self.title) - Recent"
                bookTag!.tag = newTag!
                bookTag!.book = self
            }
            // Send notification
            //            let notif = NSNotification(name: pdfWasFinished, object: self)
            //            NSNotificationCenter.defaultCenter().postNotification(notif)
            
            
        }
    }
    
    var pageIsChanged: Bool? {
        willSet {
            //print("cambiamos la pagina, ahora es \(self.pdf.lastPageOpen!.integerValue) !!!")
            let notif = Notification(name: Notification.Name(rawValue: newPageOpened), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var imageIsLoaded: Bool? {
        willSet {
            //print("IMAGEN de \(self.title) SE DESCARGO!!!")
            let notif = Notification(name: Notification.Name(rawValue: imageDidDownload), object: self)
            NotificationCenter.default.post(notif)
        }
    }
    
    var annotationsChanged: Bool? {
        willSet {
            //print("Las anotaciones de \(self.title) cambiaron!!!")
            let notif = Notification(name: Notification.Name(rawValue: annotationsDidChange), object: self)
            NotificationCenter.default.post(notif)
        }
    }
    
    var isFinished: Bool? {
        didSet {
            // Crear tag "Finished" y lanzar la notificacion para que la tabla se recargue?, con el fetched se supone que deberia recargarse sola
            if isFinished! {

                // Create and add "Finished tag"
                let newTag = Tag.uniqueTag("finished", context: self.managedObjectContext!)
                let bookTag = BookTag(managedObjectContext: self.managedObjectContext!)
                bookTag!.name = "\(self.title) - Finished"
                bookTag!.tag = newTag!
                bookTag!.book = self
                
                // Send notification
                let notif = Notification(name: Notification.Name(rawValue: pdfWasFinished), object: self)
                NotificationCenter.default.post(notif)
                
            } else {
                //print("ya no estoy leido hasta el final")
                //Quito el tag
                BookTag.removeTag("\(self.title) - Finished", fromBook: self, inContext: self.managedObjectContext!)
            }
    
        }
    }
    
    // The implementation is easier because is a NSOrderedSet
    func authorsList() -> String {
        
        var text = ""
        
        for each in self.authors {
            text += "\((each as! Author).name), "
        }
        
        //text += (self.authors.lastObject! as AnyObject).name
        
        return text
    }

    // Method is different from authorList because bookTags is a NSSet
    func tagsList() -> String? {
        
        var arrayOfTags = [String]()
        if let array = self.bookTags.allObjects as? BookTagArray {
            // go through the array except the tags __FAVORITO
            for each in array where (!(each.tag.tag == "favorite") && !(each.tag.tag == "finished")) {
                arrayOfTags.append(each.tag.tag.capitalized)
            }
            arrayOfTags.sort()
            let list = arrayOfTags.joined(separator: ", ")
            
            return list
        }
        
        return nil
    }
    
    func containsTag(_ tag: String) -> Bool {
        
        if let array = self.bookTags.allObjects as? BookTagArray {
            // go through the array except the tags __FAVORITO
            for each in array {
                if each.tag.tag == tag {
                    return true
                }
                //arrayOfTags.append(each.tag.tag.capitalizedString)
            }
        }
        
        return false
        
    }
    
}
