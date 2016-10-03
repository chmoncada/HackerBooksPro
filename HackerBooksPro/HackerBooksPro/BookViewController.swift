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
    var coreDataStack: CoreDataStack?

    var model: Book? {
        didSet {
            saveBookInUserDefaults(model!)
            saveBookIniCloud(model!)
        }
    }
    
    var currentPage: Int? {
        didSet {
            self.model?.pdf.lastPageOpen = currentPage as NSNumber?
            self.model!.isChanged = true
        }
    }
    
    var download: Download?
    
    lazy var downloadSession: URLSession = {
      
        let configuration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    // MARK: IBAction
    
    /// Start PDF downloading
    @IBAction func startDownload() {

        if let url = URL(string: model!.pdf.pdfURL) {
            progressBar.isHidden = false
            progressLabel.isHidden = false
            
            download = Download(url: model!.pdf.pdfURL)
            download!.downloadTask = downloadSession.downloadTask(with: url)
            download!.downloadTask!.resume()
        }
        
    }
    
    /// Change "Favorite" status of the `Book` object shown
    @IBAction func switchChange(_ sender: AnyObject) {
        
        model!.isFavorite = NSNumber(value: favoriteSwitch.isOn as Bool)
        
        if favoriteSwitch.isOn {

            //  Add "favorite" Tag to the book
            let newTag = Tag.uniqueTag("favorite", context: coreDataStack!.context)
            let bookTag = BookTag(managedObjectContext: coreDataStack!.context)
            bookTag!.name = "\(model!.title) - Favorite"
            bookTag!.tag = newTag!
            bookTag!.book = model!
            
        } else {
            // Remove "favorite" Tag
            BookTag.removeFavoriteTag(fromBook: model!, inContext: coreDataStack!.context)
        
        }
        model!.favIsChanged = true
        
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        _ = self.downloadSession
        
        iCloudSetup()
        
        if let book = loadBookFromiCloudOfContext(coreDataStack!.context) {
            model = book
        } else if let book = loadBookFromUserDefaultsInContext(coreDataStack!.context) {
            model = book
        } else {
            
            // As first time, we show the first book
            let fetchRequest = NSFetchRequest<Book>(entityName: Book.entityName())
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let results = try coreDataStack!.context.fetch(fetchRequest)
                model = results.first
                
            } catch let error as NSError {
                print("ERROR \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageLoaded), name: NSNotification.Name(rawValue: imageDidDownload), object: model!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    
    // MARK: - Utils
    
    /// Load the image downloaded in background, works in ipad landscape mode
    func imageLoaded() {
        coverImage.image = UIImage(data: (model?.image.imageData)! as Data)
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Refresh the view
    func refreshUI() {
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        if let data = model?.image.imageData, let img = UIImage(data: data as Data) {
            coverImage.image = img
        } else {
            coverImage.image = UIImage(named: "emptyBook")
            // load bookcover in portrait due to the Download task doesnt start in portrait because it is trigger by table cell
            if let url = URL(string: model!.image.imageURL) {
                loadDataAtURL(url){ (data: Data?) in
                    if let dataExist = data {
                        let resizeImage = UIImage(data: dataExist)!.resizedImageWithContentMode(.scaleAspectFill, bounds: CGSize(width: 112, height: 144), interpolationQuality: .default)
                        self.coverImage.image = resizeImage
                    } else {
                        self.coverImage.image = UIImage(named: "emptyBook")
                    }
                }
            }
        }
        
        tagsLabel.text = model!.tagsList()
        
        if model!.pdfDownloaded! {
            messagelabel.text = "Read the book"
        } else {
            messagelabel.text = "First download the book before read"
        }
        
        downloadButton.isHidden = model!.pdfDownloaded!
        
        // Hide Progress text and set to initial values
        progressBar.isHidden = true
        progressLabel.isHidden = true
        progressLabel.text = ""
        progressBar.progress = 0
        
        favoriteSwitch.setOn(model!.isFavorite!.boolValue, animated: true)
    }
    
    
}

// MARK: - iCloud utils

extension BookViewController {
    
    /// Setup of iCloud and set observer
    func iCloudSetup() {
        
        if FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil {
            
            let store = NSUbiquitousKeyValueStore.default()
            // Set an observer if the iCloud value changes in another device
            NotificationCenter.default.addObserver(self, selector: #selector(iCloudKeysChanged(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
            store.synchronize()
        }
        
    }
    
    /// If value change in iCloud, save it in UserDefaults so the both dictionaries are sync
    func iCloudKeysChanged(_ sender: Notification) {
        
        // Get iCloud value
        let bookIniCloud = loadBookFromiCloudOfContext(coreDataStack!.context)
        // Save it in NSUserDefaults
        if let book = bookIniCloud { saveBookInUserDefaults(book) }
        
    }
    
}

// MARK: - UITableViewDelegate

extension BookViewController {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath as NSIndexPath).section == 1 && model!.pdfDownloaded! {
            //print("me apretaste?")
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 5
        } else {
            return 30
        }
    }
    
}

//MARK: - NSURLSessionDownloadDelegate

extension BookViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = try? Data(contentsOf: location)
        
        // Check if the data is a PDF, we check the first byte for MIME type
        var c = [UInt32](repeating: 0, count: 1)
        (data! as NSData).getBytes(&c, length: 1)
        switch (c[0]) {
        case 0x25: //MIME type for PDF
            model!.pdf.pdfData = data
            
            // CREAMOS TEXTO DE PDF
            let pdfDocument = PDFDocument(bookPdf: model!.pdf)
            model!.pdf.text = pdfDocument.textOfPDF
            
            DispatchQueue.main.async(execute: {
                self.model!.isChanged = true
                self.refreshUI()
            })
        default: // all other cases
            DispatchQueue.main.async(execute: {
                self.progressBar.isHidden = true
                self.progressLabel.isHidden = true
                let alert = UIAlertController(title: "No PDF found", message: "Try to select another book from the list.  Sorry for the inconveniences", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel , handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Calculate the progress
        download?.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        // Put total size of file in MB
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
        
        DispatchQueue.main.async(execute: {
            self.progressBar.progress = (self.download?.progress)!
            self.progressLabel.text = String(format: "%.1f%% of %@",  self.download!.progress * 100, totalSize)
        })
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
    
}

// MARK: - BookSelectionDelegate

extension BookViewController: BookSelectionDelegate {
    func bookSelected(_ newBook: Book) {
        model = newBook
        refreshUI()
    }
}

// MARK: - Segue

extension BookViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPDF" {
            
            if let book = model {
                book.pdfIsOpen = true
            }
            
            let controller = segue.destination as! PDFReaderViewController
            controller.pdf = PDFDocument(bookPdf: model!.pdf)
            controller.coreDataStack = coreDataStack
            controller.book = model
            if model?.pdf.lastPageOpen?.intValue == 0 {
                controller.shouldShowPage = 1 // To avoid the page 0 in first time loading
            } else {
                controller.shouldShowPage = model?.pdf.lastPageOpen?.intValue
            }
            
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

