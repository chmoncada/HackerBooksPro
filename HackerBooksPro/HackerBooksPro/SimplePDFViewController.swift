//
//  SimplePDFViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 30/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

class SimplePDFViewController: UIViewController {
    
    var model: Book?
    var coreDataStack: CoreDataStack?
    
    @IBOutlet weak var pdfViewer: UIWebView!
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        
        //let data = NSData(contentsOfURL: loadPath)

        pdfViewer.loadData(model!.pdf.pdfData!, MIMEType: "application/pdf", textEncodingName: "", baseURL: NSURL()) // sync load, block the app

        
    }
    
}