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
    
    
    // MARK: - IBActions
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startDownload() {

        print("HOLA ME APRETASTE?")
        print(model!.pdf.pdfURL)
        if let url = NSURL(string: model!.pdf.pdfURL) {
            let download = Download(url: model!.pdf.pdfURL)
            download.downloadTask = downloadSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
        }
        
    }
    
    
    @IBAction func switchChange(sender: AnyObject) {
        
        if favoriteSwitch.on {
            print("Switch is ON")
            model!.isFavorite = NSNumber(bool: favoriteSwitch.on)
            coreDataStack!.saveContext()
        } else {
            print("Switch is OFF")
            model!.isFavorite = NSNumber(bool: favoriteSwitch.on)
            coreDataStack!.saveContext()
        }
        
    }
    
    
    // MARK: - Properties
    
    var coreDataStack: CoreDataStack?
    var model: Book?
    
    var download: Download?
    
    lazy var downloadSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        coverImage.image = UIImage(data: model!.image.imageData!)
        tagsLabel.text = model!.tagsList()
        model!.pdfDownloaded = false
        
        if model!.isFavorite!.boolValue {
            favoriteSwitch.setOn(true, animated: true)
        } else {
            favoriteSwitch.setOn(false, animated: true)
        }
        
    }
}

// MARK: - UITableViewDelegate

extension BookViewController {
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 0 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 && model!.pdfDownloaded! {
            print("ALGUN DIA SE MOSTRARA EL PDF")
            performSegueWithIdentifier("ShowPDF", sender: nil)
        } 
    }
    
}

//MARK: NSURLSessionDownloadDelegate 

extension BookViewController: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("Finished downloading")
        
        // Grabo en coredata
        model!.pdf.pdfData = NSData(contentsOfURL: location)
        model!.pdfDownloaded = true
        
        coreDataStack?.saveContext()
        
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

