//
//  PDFSearcher.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 01/10/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import CoreGraphics

class PDFSearcher {
    
    var pdfToParse: PDFDocument
    var operatorTable: CGPDFOperatorTableRef?
    var currentData: String? = ""
    
    
    
    init(pdf: PDFDocument) {
        
        self.pdfToParse = pdf
        
    }
    
    func textOfPDF() {
        
        let info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        operatorTable = CGPDFOperatorTableCreate()
        
        // We create 2 callbacks, there is 2 selectors in PDF to represent text, Tj and TJ
        CGPDFOperatorTableSetCallback(operatorTable!, "Tj") { (scanner, info) in
            
            let pdfSearcher = unsafeBitCast(info, to: PDFSearcher.self)
            var pdfString: CGPDFStringRef?
            CGPDFScannerPopString(scanner, &pdfString)
            let stringOfPDF = CGPDFStringCopyTextString(pdfString!)! as NSString
            //print("\(stringOfPDF)")
            pdfSearcher.currentData?.append(" ")
            pdfSearcher.currentData?.append(stringOfPDF as String)
        }
        
        CGPDFOperatorTableSetCallback(operatorTable!, "TJ") { (scanner, info) in
            let pdfSearcher = unsafeBitCast(info, to: PDFSearcher.self)
            
            var pdfArray: UnsafeMutablePointer<CGPDFArrayRef?>? = nil
            CGPDFScannerPopArray(scanner, pdfArray)
            var myArray = Unmanaged<CGPDFArrayRef>.fromOpaque(pdfArray!).takeUnretainedValue()
            print("Show text")
        }
        
        let numPages = pdfToParse.numberOfPages
        for pageNum in 1...numPages {
            let page = pdfToParse.PDFPage(pageNum)
            let stream = CGPDFContentStreamCreateWithPage(page!)
            let scanner = CGPDFScannerCreate(stream, operatorTable, info)
            CGPDFScannerScan(scanner)
            CGPDFScannerRelease(scanner)
            CGPDFContentStreamRelease(stream)
        }
        
    }
    
    
}
    

