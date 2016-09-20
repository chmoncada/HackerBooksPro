//
//  BookViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 30/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

class BookViewController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var messagelabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    // MARK: - Properties
    
    let UserDefaults = NSUserDefaults.standardUserDefaults()
    
    var coreDataStack: CoreDataStack?

    var model: Book? {
        didSet {
            
            // Save book in NSUserDefaults
            saveBookInUserDefaults(model!)
            
            // Save book in iCloud
            saveBookIniCloud(model!)
        }
    }
    
    var currentPage: Int? {
        didSet {
            print("Obtuve la ultima pagina leida: \(currentPage)")
            self.model?.pdf.lastPageOpen = currentPage
            self.model!.isChanged = true
            
            self.coreDataStack?.saveContext()
        }
    }
    
    var download: Download?
    
    lazy var downloadSession: NSURLSession = {
      
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSessionConfiguration")
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    @IBAction func startDownload() {

        print("Descargando...")
        if let url = NSURL(string: model!.pdf.pdfURL) {
            progressBar.hidden = false
            progressLabel.hidden = false
            
            download = Download(url: model!.pdf.pdfURL)
            download!.downloadTask = downloadSession.downloadTaskWithURL(url)
            download!.downloadTask!.resume()
        }
        
    }
    
    @IBAction func switchChange(sender: AnyObject) {
        
        favoriteSwitch.on ? print("Switch is ON") : print("Switch is OFF")
        
        model!.isFavorite = NSNumber(bool: favoriteSwitch.on)
        
        if favoriteSwitch.on {
            //cambio la propiedad del modelo isFavorite
            
            //añado "tag" favorito al modelo 
            let newTag = Tag.uniqueTag("favorite", context: coreDataStack!.context)
            let bookTag = BookTag(managedObjectContext: coreDataStack!.context)
            bookTag!.name = "\(model!.title) - Favorite"
            bookTag!.tag = newTag!
            bookTag!.book = model!
            
        } else {
            
            BookTag.removeFavoriteTag(fromBook: model!, inContext: coreDataStack!.context)
        
        }
        model!.favIsChanged = true
        
        coreDataStack!.saveContext()
        
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _ = self.downloadSession
        
        if let book = loadBookFromiCloud() {
            print("encontre modelo en iCloud: \(book.title)")
            model = book
        } else if let book = loadBookFromUserDefaults() {
            print("encontre modelo en NSUserDefaults: \(book.title)")
            model = book
        } else {
            
            // Cargo el primer libro por ahora
            let fetchRequest = NSFetchRequest(entityName: Book.entityName())
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let results = try coreDataStack!.context.executeFetchRequest(fetchRequest) as! [Book]
                print("No encontre nada, muestro el libro: \(results.first!.title)")
                model = results.first
                
            } catch let error as NSError {
                print("ERROR \(error)")
            }
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(imageLoaded), name: imageDidDownload, object: model!)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshUI()
    }
    
    
    // MARK: - Utils
    
    func imageLoaded() {
        coverImage.image = UIImage(data: (model?.image.imageData)!)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refreshUI() {
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        if let data = model?.image.imageData, let img = UIImage(data: data) {
            coverImage.image = img
        } else {
            coverImage.image = UIImage(named: "emptyBook")
        }
        
        tagsLabel.text = model!.tagsList()
        
        if model!.pdfDownloaded! {
            messagelabel.text = "Read the book"
        } else {
            messagelabel.text = "First download the book before read"
        }
        
        downloadButton.hidden = model!.pdfDownloaded!
        
        // Hide Progress text and set to initial values
        progressBar.hidden = true
        progressLabel.hidden = true
        progressLabel.text = ""
        progressBar.progress = 0
        
        favoriteSwitch.setOn(model!.isFavorite!.boolValue, animated: true)
    }
    
    
}

// MARK: - NSUserDefaults methods & iCloud

extension BookViewController {
    
    func saveBookInUserDefaults(book: Book) {
        
        // Obtain the NSData
        if let data = archiveURIRepresentation(book) {
            // save in userdefaults
            UserDefaults.setObject(data, forKey: "lastbookopen")
        }
    }
    
    func loadBookFromUserDefaults() -> Book? {
        if let uriDefault = UserDefaults.objectForKey("lastbookopen") as? NSData {
            return objectWithArchivedURIRepresentation(uriDefault, context: coreDataStack!.context)
        }
        
        return nil
    }
    
    func saveBookIniCloud(book: Book) {
        
        // Set the iCloud store
        let store = NSUbiquitousKeyValueStore.defaultStore()
        // Obtain the NSData
        if let data = archiveURIRepresentation(book) {
            store.setObject(data, forKey: "lastbookopen")

        }

    }
    
    func loadBookFromiCloud() -> Book? {
        let store = NSUbiquitousKeyValueStore.defaultStore()
        if let uriDefault = store.objectForKey("lastbookopen") as? NSData {
            return objectWithArchivedURIRepresentation(uriDefault, context: coreDataStack!.context)
        }
        
        return nil
    }
    
    func archiveURIRepresentation(book: Book) -> NSData? {
        let uri = book.objectID.URIRepresentation()
        return NSKeyedArchiver.archivedDataWithRootObject(uri)
        
    }
    
    func objectWithArchivedURIRepresentation(archivedURI: NSData, context: NSManagedObjectContext) -> Book? {
        
        if let uri: NSURL = NSKeyedUnarchiver.unarchiveObjectWithData(archivedURI) as? NSURL, let nid = context.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(uri) {
            let book = context.objectWithID(nid) as! Book
            return book
        }
        
        return nil
    }
    
}

// MARK: - UITableViewDelegate

extension BookViewController {
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && model!.pdfDownloaded! {
            //print("me apretaste?")
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 5
        } else {
            return 30
        }
    }
    
}

//MARK: - NSURLSessionDownloadDelegate

extension BookViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)
        
        // Check if the data is a PDF, we check the first byte for MIME type
        var c = [UInt32](count: 1, repeatedValue: 0)
        data!.getBytes(&c, length: 1)
        switch (c[0]) {
        case 0x25: //MIME type for PDF
            model!.pdf.pdfData = data
            dispatch_async(dispatch_get_main_queue(), {
                self.model!.isChanged = true
                self.refreshUI()
                self.coreDataStack?.saveContext()
            })
        default: // all other cases
            dispatch_async(dispatch_get_main_queue(), {
                self.progressBar.hidden = true
                self.progressLabel.hidden = true
                let alert = UIAlertController(title: "No PDF found", message: "Try to select another book from the list.  Sorry for the inconviniences", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Cancel , handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Calculate the progress
        download?.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        // Put total size of file in MB
        let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.progressBar.progress = (self.download?.progress)!
            self.progressLabel.text = String(format: "%.1f%% of %@",  self.download!.progress * 100, totalSize)
        })
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }
    
}

// MARK: - BookSelectionDelegate

extension BookViewController: BookSelectionDelegate {
    func bookSelected(newBook: Book) {
        //print("se activa el delegado!!")
        model = newBook
        refreshUI()
    }
}

// MARK: - Segue

extension BookViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPDF" {
            
            let controller = segue.destinationViewController as! PDFReaderViewController

            controller.pdf = PDFDocument(bookPdf: model!.pdf)
            controller.coreDataStack = coreDataStack
            controller.book = model
            if model?.pdf.lastPageOpen?.integerValue == 0 {
                controller.shouldShowPage = 1 // To avoid the page 0 in first time loading
            } else {
                controller.shouldShowPage = model?.pdf.lastPageOpen?.integerValue
            }
            
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

