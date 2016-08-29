//
//  BookCell.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 23/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

class BookCell: UITableViewCell {
    
    @IBOutlet weak var BookTitle: UILabel!
    @IBOutlet weak var BookAuthors: UILabel!
    @IBOutlet weak var BookCover: UIImageView!
    
    var downloadTask: NSURLSessionDownloadTask?
    
    func configureCell(fetchResultController: NSFetchedResultsController, indexPath: NSIndexPath, coreDataStack: CoreDataStack) {
        
        let book = fetchResultController.objectAtIndexPath(indexPath) as! Book
        self.BookTitle.text = book.title
        self.BookAuthors.text = "AUTORES"
        
        // Si no hay datos en el modelo se carga y se retorna la info
        guard (book.image.imageData != nil) else {
            print("NO hay datos en el coredata")
            self.BookCover.image = UIImage(named: "emptyBook")
            if let url = NSURL(string: book.image.imageURL) {
                loadImage(remoteURL: url){ (image: UIImage?, data: NSData?) in
                    // Se reemplaza con el descargado
                    print("se usa imagen descargada")
                    self.BookCover.image = image
                    book.image.imageData = data
                    coreDataStack.saveContext()
                }
            }
            return
        }
        
        print(" se usa los datos de Core Data")
        self.BookCover.image = UIImage(data:book.image.imageData!)
        
    }

}
