//
//  PDFReaderViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 31/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//  Ideas and some code from https://github.com/Dean151/PDF-reader-iOS
//

import UIKit
import WebKit
import CoreData

class PDFReaderViewController: UIViewController, UIWebViewDelegate {

    // MARK: - IBOutlets
    
    @IBOutlet weak var overviewButton: UIBarButtonItem!
    @IBOutlet weak var webview : UIWebView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack?
    var book: Book?
    var shouldShowPage: Int?
    var shouldReload = false
    
    var pdf: PDFDocument? {
        didSet {
            // Update the view.
            self.configureView()
            self.shouldReload = true
            //self.shouldShowPage = nil
        }
    }
    
    var annotationPages = Set<Int>()

    // MARK: - Utils
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let pdf = self.pdf else {
            print("no pdf");
            return
        }
        self.navigationItem.title = pdf.name
    }
    
    func getAnnotationPages() {
      
        // First we need to fetch all the annotations that belongs to the book
        //var foundNotes = [Annotation]()
        
        let fetchRequest: NSFetchRequest<Annotation> = NSFetchRequest()
        let entity = Annotation.entity()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "bookPdf.book == %@", book!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "linkedPage", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            let foundNotes = try coreDataStack?.context.fetch(fetchRequest)
            for each in foundNotes! {
                let page = each.linkedPage!.intValue
                annotationPages.insert(page)
            }
            //print("las paginas que tienen anotaciones son: \(annotationPages)")
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            
        }
        
    }
    
    func annotationSetChanged() {
        //print("detecte el cambio de las anotaciones, debo refrescar el set")
        getAnnotationPages()
    }
    
    func dismissView() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.delegate = self
        if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
             // Preventing having page under Navigation Controller
            self.webview.scrollView.contentInset = UIEdgeInsets(top: navBarOffset, left: 0, bottom: 0, right: 0)
            //lo hacemos delegado
            self.webview.scrollView.delegate = self
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(annotationSetChanged), name: NSNotification.Name(rawValue: annotationsDidChange), object: book!)
        nc.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name(rawValue: selectAnotherBook), object: nil)
        
        getAnnotationPages()
        self.configureView()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        self.webview.scrollView.delegate = nil
        self.webview = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Opening pdf file
        webview.load(pdf!.data! as Data, mimeType: "application/pdf", textEncodingName: "", baseURL: URL(string: "www.google.com")!)
        
        
        if shouldReload {
            //print("se recarga pdf")
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            webview.load(pdf!.data! as Data, mimeType: "application/pdf", textEncodingName: "", baseURL: URL(string: "www.google.com")!)
            
            webview.scrollView.isScrollEnabled = true
            shouldReload = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowOverview" {
            
            guard let pdf = self.pdf else {
                return
            }
            
            let controller = (segue.destination as! UINavigationController).topViewController as! PDFOverviewViewController
            controller.pdf = pdf
            controller.parentVC = self
            if let currentPage = self.currentPage {
                //print("Estamos en la pagina: \(currentPage)")
                controller.currentPage = currentPage
            }
            
        } else if segue.identifier == "AddAnnotation" {
            
            shouldShowPage = currentPage
            let controller = (segue.destination as! UINavigationController).topViewController as! AnnotationViewController
            if let currentPage = self.currentPage {
                //print("Estamos en la pagina: \(currentPage)")
                controller.currentPage = currentPage
            }
            controller.coreDataStack = coreDataStack
            controller.book = book
            
        } else if segue.identifier == "ShowAnnotations" {
            
            shouldShowPage = currentPage
            let controller = segue.destination as! UITabBarController
            let barViewController = controller.viewControllers
            let notesCollection = barViewController![0] as! AnnotationsCollectionViewController
            let mapView = barViewController![1] as! MapViewController
            notesCollection.coreDataStack = coreDataStack
            mapView.coreDataStack = coreDataStack
            
            notesCollection.book = book
            mapView.book = book
            
            notesCollection.pdf = pdf
            
        }

    }
    
    // MARK: - Web Methods
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //print("termino de cargar LA VISTA")
        self.changePage()
    }
    
    // MARK: - Page Handling
    
    var currentPage: Int? {
        guard let nbPages = pdf?.numberOfPages else {
            return nil
        }
        let paddingSize: CGFloat = 10
        
        let allHeight = self.webview.scrollView.contentSize.height
        let allPadding = paddingSize * CGFloat(nbPages+1)
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        
        let currentPage = Int( round(self.webview.scrollView.contentOffset.y / (paddingSize+pageHeight)) ) + 1
        return currentPage
    }
    
    var oldPage: Int = 0
    
    func changePage() {
        if let page = self.shouldShowPage {
            self.shouldShowPage = nil // Prevent for changing page again
            //print("nos movemos a la pagina \(page)")
            self.goToPage(page)
        }
    }
    
    func goToPage(_ page: Int) {
        guard let nbPages = pdf?.numberOfPages else {
            return
        }
        let paddingSize: CGFloat = 10
        
        let allHeight = self.webview.scrollView.contentSize.height
        //print("allHeight: \(allHeight)")
        let allPadding = paddingSize * CGFloat(nbPages+1)
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        //print("pageHeight: \(pageHeight)")
        
        if page <= nbPages && page >= 0 {
            var offsetPoint = CGPoint(x: 0, y: (paddingSize+pageHeight)*CGFloat(page-1))
            if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
                offsetPoint.y -= navBarOffset + paddingSize // Preventing having page under Navigation Controller
            }
            //print("offsetPoint: \(offsetPoint)")
            self.webview.scrollView.setContentOffset(offsetPoint, animated: false)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PDFReaderViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Check if we are in the last page
        if currentPage == pdf?.numberOfPages {
            // Check if the bool value are not nil
            if book!.isFinished != nil {
                // to avoid assing true to the variable that is already true
                if !(book?.isFinished)!  {
                    book?.isFinished = true
                }
            } else {
                book?.isFinished = true
            }
        } else {
            book?.isFinished = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if currentPage! != oldPage && currentPage! > 0 {
            //print("pagina nueva: \(currentPage!), debo lanzar notificacion")
            book?.pdf.lastPageOpen = currentPage! as NSNumber?
            book?.pageIsChanged = true
            oldPage = currentPage!
        }
        
        if annotationPages.contains(currentPage!) {
            bookmarkButton.image = UIImage(named: "bookmarkRibbonFilled")
        } else {
            bookmarkButton.image = UIImage(named: "bookmarkRibbon")
        }
        
    }
    
}
