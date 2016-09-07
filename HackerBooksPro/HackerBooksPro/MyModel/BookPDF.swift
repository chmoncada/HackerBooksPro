import Foundation
import UIKit

@objc(BookPDF)
public class BookPDF: _BookPDF {
	
    var document: PDFDocument? {
        
        let pdfDocument = PDFDocument(bookPdf: self)
        
        return pdfDocument
    }
    
    
    
}
