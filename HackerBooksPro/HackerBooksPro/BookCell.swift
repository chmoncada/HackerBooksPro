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
    @IBOutlet weak var BookPageStatus: UILabel!
    
    @IBOutlet weak var FavImage: UIImageView!
    
    var downloadTask: NSURLSessionDownloadTask?
    
    func configureCell(fetchResultController: NSFetchedResultsController, indexPath: NSIndexPath, coreDataStack: CoreDataStack) {
        
        let bookTag = fetchResultController.objectAtIndexPath(indexPath) as! BookTag
        let book = bookTag.book
        
        // Actualizo labels de titulo y autores
        self.BookTitle.text = book.title
        self.BookAuthors.text = book.authorsList()
        
        //print("\(book.title) FAVORITE STATUS: \(book.isFavorite!.boolValue)")
        //self.FavStar.selected = book.isFavorite!.boolValue
 
        // seteo la estrella de Favorito
        if book.isFavorite!.boolValue {
            FavImage.image = UIImage(named: "filledStar")
        } else {
            FavImage.image = UIImage(named: "emptyStar")
        }
        
        // Seteo el page status
        //POR AHORA MUESTRO LAS PAGINAS DEL LIBRO
        if book.pdf.pdfData != nil {
            BookPageStatus.text = "Paginas totales: \(book.pdf.numberOfPages)"
        } else {
            BookPageStatus.text = "Not available"
        }
        
        
        // Seteo la imagen
        // Si no hay datos en el modelo se carga y se retorna la info
        guard (book.image.imageData != nil) else {
            print("NO hay imagen guardada en el modelo")
            self.BookCover.image = UIImage(named: "emptyBook")
            if let url = NSURL(string: book.image.imageURL) {
                loadImage(remoteURL: url){ (image: UIImage?, data: NSData?) in
                    
                    if let imgExist = image, let dataExist = data {
                        print("se usa imagen descargada")
                        self.BookCover.image = imgExist
                        book.image.imageData = dataExist
                        coreDataStack.saveContext()
                    } else {
                        print("No se pudo descargar imagen, se usara la imagen por defecto")
                        self.BookCover.image = UIImage(named: "emptyBook")
                    }

                }
            }
            return
        }
        
        print(" se usa los datos de Core Data")
        self.BookCover.image = UIImage(data:book.image.imageData!)
        
        
        
    }

}
