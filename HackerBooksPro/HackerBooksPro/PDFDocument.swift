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
    var url: URL? = nil
    var data: Data?
    var document: CGPDFDocument? = nil
    
    init(name: String, url: URL) throws {
        self.name = name
        self.url = url
        guard let doc = CGPDFDocument(url as CFURL) else {
            throw PDFDocumentError.badDocumentType
        }
        self.document = doc
    }
    
    init(bookPdf: BookPDF) {
        
        self.name = bookPdf.book.title
        
        self.data = bookPdf.pdfData! as Data
        let pdfDataRef = data
        let provider = CGDataProvider(data: pdfDataRef! as CFData)
        let doc = CGPDFDocument(provider!)
        
        self.document = doc
        
        
    }
    
    var textOfPDF: String? {
        // PRUEBA DE SCANNER
        let prueba = PDFSearcher(pdf: self)
        prueba.textOfPDF()
        
        return prueba.currentData
    }
    
    var numberOfPages: Int {
        return self.document!.numberOfPages
    }
    
    func isPageInDocument(_ page: Int) -> Bool {
        return page > 0 && page <= self.numberOfPages
    }
    
    // Thumbnail handling
    func PDFPage(_ page: Int) -> CGPDFPage? {
        guard let document = self.document else { print("no document"); return nil }
        return document.page(at: page)
    }
    
    func rectFromPDFWithPage(_ page: Int) -> CGRect? {
        guard let docPage = self.PDFPage(page) else { return nil }
        return docPage.getBoxRect(.mediaBox)
    }
    
    func imageFromPDFWithPage(_ page: Int) -> UIImage? {
        guard let docPage = self.PDFPage(page) else { return nil }
        let pageRect = self.rectFromPDFWithPage(page)!
        
        UIGraphicsBeginImageContext(pageRect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
        context.fill(pageRect)
        context.saveGState()
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.concatenate(docPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
        context.drawPDFPage(docPage)
        context.restoreGState()
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image;
    }
}
