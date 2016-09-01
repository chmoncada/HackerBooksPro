//
//  PDFDocument.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 31/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

class PDFDocument {
    let name: String
    var url: NSURL? = nil
    var data: NSData?
    var document: CGPDFDocument? = nil
    
//    init(name: String, url: NSURL) throws {
//        self.name = name
//        self.url = url
//        guard let doc = CGPDFDocumentCreateWithURL(url) else {
//            throw PDFDocumentError.BadDocumentType
//        }
//        self.document = doc
//    }
    
    init(bookPdf: BookPDF) {
        
        self.name = bookPdf.book.title
        
        self.data = bookPdf.pdfData!
        let pdfDataRef = data
        let provider = CGDataProviderCreateWithCFData(pdfDataRef)
        let doc = CGPDFDocumentCreateWithProvider(provider)
        
        self.document = doc
    }
    
    var numberOfPages: Int {
        return CGPDFDocumentGetNumberOfPages(self.document)
    }
    
    func isPageInDocument(page: Int) -> Bool {
        return page > 0 && page <= self.numberOfPages
    }
    
    // Thumbnail handling
    func PDFPage(page: Int) -> CGPDFPage? {
        guard let document = self.document else { print("no document"); return nil }
        return CGPDFDocumentGetPage(document, page)
    }
    
    func rectFromPDFWithPage(page: Int) -> CGRect? {
        guard let docPage = self.PDFPage(page) else { return nil }
        return CGPDFPageGetBoxRect(docPage, .MediaBox)
    }
    
    func imageFromPDFWithPage(page: Int) -> UIImage? {
        guard let docPage = self.PDFPage(page) else { return nil }
        let pageRect = self.rectFromPDFWithPage(page)!
        
        UIGraphicsBeginImageContext(pageRect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0)
        CGContextFillRect(context,pageRect)
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0.0, pageRect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(docPage, .MediaBox, pageRect, 0, true))
        CGContextDrawPDFPage(context, docPage)
        CGContextRestoreGState(context)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}