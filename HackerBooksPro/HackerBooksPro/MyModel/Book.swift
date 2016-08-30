import Foundation

@objc(Book)
public class Book: _Book {
	
    
    func authorsList() -> String {
        
        var text = ""
        
        for each in self.authors where each !== self.authors.lastObject{
            text += "\(each.name!), "
        }
        
        text += self.authors.lastObject!.name
        
        return text
    }

    func tagsList() -> String? {
        
        if let array = self.bookTags.allObjects as? BookTagArray {
            let arrayOfTags = array.map({$0.tag.tag!})
            return arrayOfTags.joinWithSeparator(", ")
        }
        
        return nil
    }
    
    
}
