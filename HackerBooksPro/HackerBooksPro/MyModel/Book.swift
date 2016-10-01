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
            let notif = Notification(name: Notification.Name(rawValue: modelDidChange), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var favIsChanged: Bool? {
        willSet {
            let notif = Notification(name: Notification.Name(rawValue: favStatusDidChange), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var pdfIsOpen: Bool? {
        didSet {
            self.pdf.lastTimeOpened = Date()
            
            // if tag "recent" is not in the book
            if !self.containsTag("recent") {
                
                // Create and add "Recent tag"
                let newTag = Tag.uniqueTag("recent", context: self.managedObjectContext!)
                
                let bookTag = BookTag(managedObjectContext: self.managedObjectContext!)
                bookTag!.name = "\(self.title) - Recent"
                bookTag!.tag = newTag!
                bookTag!.book = self
            }
        }
    }
    
    var pageIsChanged: Bool? {
        willSet {

            let notif = Notification(name: Notification.Name(rawValue: newPageOpened), object: self)
            NotificationCenter.default.post(notif)
            
        }
    }
    
    var imageIsLoaded: Bool? {
        willSet {
            let notif = Notification(name: Notification.Name(rawValue: imageDidDownload), object: self)
            NotificationCenter.default.post(notif)
        }
    }
    
    var annotationsChanged: Bool? {
        willSet {
            let notif = Notification(name: Notification.Name(rawValue: annotationsDidChange), object: self)
            NotificationCenter.default.post(notif)
        }
    }
    
    var isFinished: Bool? {
        didSet {

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
                // Remove tag
                BookTag.removeTag("\(self.title) - Finished", fromBook: self, inContext: self.managedObjectContext!)
            }
    
        }
    }
    
    func authorsList() -> String {
        
        var text = ""
        
        for each in self.authors {
            text += "\((each as! Author).name), "
        }
        
        // Remove the last 2 character of the list (an extra ", ")
        text.remove(at: text.index(before: text.endIndex))
        text.remove(at: text.index(before: text.endIndex))
        
        return text
    }

    // Method is different from authorList because bookTags is a NSSet
    func tagsList() -> String? {
        
        var arrayOfTags = [String]()
        if let array = self.bookTags.allObjects as? BookTagArray {
            // go through the array except the pseudo "tags"
            for each in array where (!(each.tag.tag == "favorite") && !(each.tag.tag == "finished")  && !(each.tag.tag == "recent")) {
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
            for each in array {
                if each.tag.tag == tag {
                    return true
                }
            }
        }
        return false
    }
    
}
