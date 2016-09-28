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
        return UIScreen.main.bounds.width/5
    }
    
    var prueba: String?
    var coreDataStack: CoreDataStack?
    var book: Book?
    var pdf: PDFDocument?
    
    var fetchRequest: NSFetchRequest<Annotation> {
        
        let request = NSFetchRequest<Annotation>(entityName: Annotation.entityName())
        
        let predicate = NSPredicate(format: "bookPdf.book == %@", book!)
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "linkedPage", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    var annotations: [Annotation]? {
        
        //var foundNotes = [Annotation]()
        
        do {
            let foundNotes = try coreDataStack?.context.fetch(fetchRequest)
            return foundNotes
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return nil
        }
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name(rawValue: selectAnotherBook), object: nil)
        
    }
    
    func dismissView() {
        //self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return annotations!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
    
        let pageNumber = annotations![(indexPath as NSIndexPath).row].linkedPage?.intValue
        
        // Configure the cell
        cell.textLabel.text = "Page \(pageNumber!)"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        cell.titleLabel.text = "\(formatter.string(from: annotations![(indexPath as NSIndexPath).row].creationDate as Date))"
        
        // We put it async
        DispatchQueue.global(qos: .default).async {
            // If nil, useless to go further
            guard let image = self.pdf?.imageFromPDFWithPage(pageNumber!) else { return }
            DispatchQueue.main.async {
                    cell.imageView.image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: CGSize(width: 121, height: 156), interpolationQuality: .high)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditAnnotation" {
            
            let controller = (segue.destination as! UINavigationController).topViewController as! AnnotationViewController

            if let indexPath = collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                let annotation = annotations![(indexPath as NSIndexPath).row]
                controller.annotationToEdit = annotation
            }
            
            controller.coreDataStack = coreDataStack
            controller.book = book
        }
    }
    
}
