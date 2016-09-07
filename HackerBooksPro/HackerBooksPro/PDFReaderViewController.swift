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


class PDFReaderViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var overviewButton: UIBarButtonItem!
    
    @IBOutlet weak var webview : UIWebView!
    
    var shouldShowPage: Int?
    var shouldReload = false
    
    weak var parentVC : BookViewController?
    
    var pdf: PDFDocument? {
        didSet {
            // Update the view.
            self.configureView()
            self.shouldReload = true
            //self.shouldShowPage = nil
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let pdf = self.pdf else {
            print("no pdf");
            return
        }
        self.navigationItem.title = pdf.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.webview = WKWebView(frame: self.view.bounds)
        
        //self.webview = UIWebView(frame: self.view.bounds)
        
        self.webview.delegate = self
        if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
             // Preventing having page under Navigation Controller
            self.webview.scrollView.contentInset = UIEdgeInsets(top: navBarOffset, left: 0, bottom: 0, right: 0)
            //lo hacemos delegado
            self.webview.scrollView.delegate = self
        }
        //self.view.addSubview(self.webview)
        
        self.configureView()
    }
    
    deinit {
        self.webview.scrollView.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        // Opening pdf file
//        guard let url = pdf?.url else {
//            print("no URL for file")
//            self.navigationItem.rightBarButtonItem?.enabled = false
//            let url = NSBundle.mainBundle().URLForResource("nofile", withExtension: "html")!
//            let request = NSURLRequest(URL: url)
//            webview.loadRequest(request)
//            webview.scrollView.scrollEnabled = false
//            return
//        }
        
        //webview.loadData(pdf!.data!, MIMEType: "application/pdf", characterEncodingName: "", baseURL: NSURL())
        webview.loadData(pdf!.data!, MIMEType: "application/pdf", textEncodingName: "", baseURL: NSURL())
        
        
        if shouldReload {
            print("se recarga pdf")
            self.navigationItem.rightBarButtonItem?.enabled = true
            //let request = NSURLRequest(URL: url)
            //webview.loadRequest(request)
            //webview.loadData(pdf!.data!, MIMEType: "application/pdf", characterEncodingName: "", baseURL: NSURL())
            webview.loadData(pdf!.data!, MIMEType: "application/pdf", textEncodingName: "", baseURL: NSURL())
            
            webview.scrollView.scrollEnabled = true
            shouldReload = false
        }
    }

    override func viewWillDisappear(animated: Bool) {
        print("Me quede leyendo la pagina: \(currentPage)")
        guard let parentVC = self.parentVC else {
            print("no encontre al parentVC")
            return
        }
        parentVC.currentPage = currentPage
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    deinit {
//        self.webview.scrollView.delegate = nil
//    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowOverview" {
            guard let pdf = self.pdf else {
                return
            }
            
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PDFOverviewViewController
            controller.pdf = pdf
            controller.parentVC = self
            if let currentPage = self.currentPage {
                print("Estamos en la pagina: \(currentPage)")
                controller.currentPage = currentPage
            }
        }
    }
    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        self.changePage()
//    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("termino de cargar LA VISTA")
        print(self.shouldShowPage)
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
    
    func changePage() {
        if let page = self.shouldShowPage {
            self.shouldShowPage = nil // Prevent for changing page again
            print("nos movemos a la pagina \(page)")
            self.goToPage(page)
        }
    }
    
    func goToPage(page: Int) {
        guard let nbPages = pdf?.numberOfPages else {
            return
        }
        let paddingSize: CGFloat = 10
        
        let allHeight = self.webview.scrollView.contentSize.height
        print("allHeight: \(allHeight)")
        let allPadding = paddingSize * CGFloat(nbPages+1)
        let pageHeight = (allHeight-allPadding)/CGFloat(nbPages)
        print("pageHeight: \(pageHeight)")
        
        if page <= nbPages && page >= 0 {
            var offsetPoint = CGPointMake(0, (paddingSize+pageHeight)*CGFloat(page-1))
            if let navBarOffset = self.navigationController?.navigationBar.frame.size.height {
                offsetPoint.y -= navBarOffset + paddingSize // Preventing having page under Navigation Controller
            }
            print("offsetPoint: \(offsetPoint)")
            self.webview.scrollView.setContentOffset(offsetPoint, animated: false)
        }
    }
}
extension PDFReaderViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if currentPage == pdf?.numberOfPages {
            print("SE ACABO")            
        }
        
    }
    
}
