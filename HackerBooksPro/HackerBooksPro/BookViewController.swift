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
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    // MARK: - Properties
    
    var coreDataStack: CoreDataStack?
    var model: Book?
    
    var download: Download?
    
    lazy var downloadSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    // MARK: - IBActions
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startDownload() {

        print("HOLA ME APRETASTE?")
        if let url = NSURL(string: model!.pdf.pdfURL) {
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
        super.viewDidLoad()
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        coverImage.image = UIImage(data: model!.image.imageData!)
        tagsLabel.text = model!.tagsList()
        
        downloadButton.hidden = model!.pdfDownloaded!
        progressBar.hidden = model!.pdfDownloaded!
        progressLabel.hidden = model!.pdfDownloaded!
        
        favoriteSwitch.setOn(model!.isFavorite!.boolValue, animated: true)
        
    }
}

// MARK: - UITableViewDelegate

extension BookViewController {
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && model!.pdfDownloaded! {
            print("me apretaste?")
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
        
        dispatch_async(dispatch_get_main_queue(), {
            self.downloadButton.hidden = true
            self.progressBar.hidden = true
            self.progressLabel.hidden = true
            
        })
        
//        // Grabo en coredata
        model!.pdf.pdfData = NSData(contentsOfURL: location)
        model!.isChanged = true
        
        coreDataStack?.saveContext()
        
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Calculate the progress
        download?.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        // Put total size of file in MB
        let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
        
        print(download?.progress)
        print(totalSize)
        dispatch_async(dispatch_get_main_queue(), {
            self.progressBar.progress = (self.download?.progress)!
            self.progressLabel.text = String(format: "%.1f%% of %@",  self.download!.progress * 100, totalSize)
            
        })
    }
    
    
}

// MARK: - Segue

extension BookViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPDF" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! PDFReaderViewController
            //let url = NSBundle.mainBundle().URLForResource("iosreverseengineering", withExtension: "pdf")
            
//            do {
                controller.pdf = PDFDocument(bookPdf: model!.pdf)
//            } catch {
//                print("PDF could not be created")
//            }
            
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

