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
//    var model: Book? {
//        didSet {
//            print("Me cambiaron!!, no deberias actualizar la vista???")
//            refreshUI()
//        }
//    }
    var model: Book? {
        didSet {
            print("ahora soy: \(model?.title)")
            print("deberias grabarme en el NSUserDefaults")
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
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    // MARK: - IBActions
    
//    @IBAction func done() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
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
            let newTag = Tag.uniqueTag("__FAVORITO", context: coreDataStack!.context)
            let bookTag = BookTag(managedObjectContext: coreDataStack!.context)
            bookTag!.name = "\(model!.title) - Favorite"
            bookTag!.tag = newTag!
            bookTag!.book = model!
            
            //FUNCIONO, FALTA ARREGLAR LAS SECCIONES DEL FETCHED RESULTS CONTROLLER
            //1 busco si tag existe
        } else {
            BookTag.removeFavoriteTag(fromBook: model!, inContext: coreDataStack!.context)
        }
        model!.isChanged = true
        
        coreDataStack!.saveContext()
        
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        
        // Cargo el primer libro por ahora
        let fetchRequest = NSFetchRequest(entityName: Book.entityName())
        let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try coreDataStack!.context.executeFetchRequest(fetchRequest) as! [Book]
            print("encontre primer libro")
            model = results.first
            
        } catch let error as NSError {
            print("ERROR \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshUI()
    }
    
    // MARK: - Utils
    
    func refreshUI() {
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        if let data = model?.image.imageData, let img = UIImage(data: data) {
            coverImage.image = img
        } else {
            coverImage.image = UIImage(named: "emptyBook")
        }
        
        tagsLabel.text = model!.tagsList()
        
        // Averiguo el numero de hojas del PDF
//        if (model?.pdf.pdfData) != nil {
//            let paginas = model!.pdf.document!.numberOfPages
//            print("el numero de paginas de \(model!.title) es: \(paginas)")
//        } else {
//            print("Aun no se descarga el PDF")
//        }
        
        
        
        //progressLabel.text = ""
        //progressBar.progress = 0
        
        if model!.pdfDownloaded! {
            messagelabel.text = "Read the book"
        } else {
            messagelabel.text = "First download the book before read"
        }
        
        downloadButton.hidden = model!.pdfDownloaded!
        progressBar.hidden = true
        progressLabel.hidden = true
        
        favoriteSwitch.setOn(model!.isFavorite!.boolValue, animated: true)
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
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 1 && indexPath.row == 0 && model!.pdfDownloaded! {
//            print("ALGUN DIA SE MOSTRARA EL PDF")
//            //performSegueWithIdentifier("ShowPDF", sender: nil)
//        } 
//    }
    
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
        print("Finished downloading")
        model!.pdf.pdfData = NSData(contentsOfURL: location)

        dispatch_async(dispatch_get_main_queue(), {
            //self.downloadButton.hidden = true
            //self.progressBar.hidden = true
            //self.progressLabel.hidden = true
            
            //self.model!.pdf.pdfData = NSData(contentsOfURL: location)
            self.model!.isChanged = true
            
            self.refreshUI()
            
            self.coreDataStack?.saveContext()

            
        })
        
//        // Grabo en coredata
        //        model!.isChanged = true
//        
//        coreDataStack?.saveContext()
        
        
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
    
    
}

// MARK: - BookSelectionDelegate

extension BookViewController: BookSelectionDelegate {
    func bookSelected(newBook: Book) {
        print("se activa el delegado!!")
        model = newBook
        refreshUI()
    }
}

// MARK: - Segue

extension BookViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPDF" {
            
            let controller = segue.destinationViewController as! PDFReaderViewController
            //let  = navigationController.topViewController as!
            //let url = NSBundle.mainBundle().URLForResource("iosreverseengineering", withExtension: "pdf")
            
//            do {
            controller.pdf = PDFDocument(bookPdf: model!.pdf)
            controller.parentVC = self
            if model?.pdf.lastPageOpen?.integerValue == 0 {
                controller.shouldShowPage = 1 // To avoid the page 0 in first time loading
            } else {
                controller.shouldShowPage = model?.pdf.lastPageOpen?.integerValue
            }
//            } catch {
//                print("PDF could not be created")
//            }
            
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

