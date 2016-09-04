import Foundation
import UIKit

@objc(BookPDF)
public class BookPDF: _BookPDF {
	
    var document: CGPDFDocument? {
        let provider = CGDataProviderCreateWithCFData(self.pdfData)
        let doc = CGPDFDocumentCreateWithProvider(provider)
        
        return doc
    }
    
    var numberOfPages: Int {
        return CGPDFDocumentGetNumberOfPages(self.document)
    }
    
    
    
    
}
