//
//  AnnotationsCollectionViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 17/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "NoteCell"

class AnnotationsCollectionViewController: UICollectionViewController {

    // Calculate widht of eachNote so we can show always 4 notes in a row
    var widthForNote: CGFloat {
        return UIScreen.mainScreen().bounds.width/5
    }
    
    var prueba: String?
    var coreDataStack: CoreDataStack?
    var book: Book?
    var pdf: PDFDocument?
    
    var fetchRequest: NSFetchRequest {
        
        let request = NSFetchRequest()
        let entity = Annotation.entity()
        request.entity = entity
        
        let predicate = NSPredicate(format: "bookPdf.book == %@", book!)
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "linkedPage", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    var annotations: [Annotation]? {
        
        var foundNotes = [Annotation]()
        
        do {
            foundNotes = try coreDataStack?.context.executeFetchRequest(fetchRequest) as! [Annotation]
            return foundNotes
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return nil
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return annotations!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
    
        let pageNumber = annotations![indexPath.row].linkedPage?.integerValue
        
        // Configure the cell
        cell.textLabel.text = "Page \(pageNumber!)"
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        cell.titleLabel.text = "\(formatter.stringFromDate(annotations![indexPath.row].creationDate))"
        
        // We put it async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            // If nil, useless to go further
            guard let image = self.pdf?.imageFromPDFWithPage(pageNumber!) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                    cell.imageView.image = image.resizedImageWithContentMode(.ScaleAspectFit, bounds: CGSizeMake(121, 156), interpolationQuality: .High)
            }
        }
        
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension AnnotationsCollectionViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EditAnnotation" {
            
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AnnotationViewController

            if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let annotation = annotations![indexPath.row]
                controller.annotationToEdit = annotation
            }
            
            // ARREGLAR ESTO
            //controller.currentPage = 1
            controller.coreDataStack = coreDataStack
            controller.book = book
        }
    }
    
}
