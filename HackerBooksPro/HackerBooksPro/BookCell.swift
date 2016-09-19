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
    
    var _book: Book?
    let _nc = NSNotificationCenter.defaultCenter()
    var _bookObserver : NSObjectProtocol?
    
    var downloadTask: NSURLSessionDownloadTask?
    
    // MARK: - Observing methods
    
    func startObserving(book: Book){
        _book = book
        _nc.addObserverForName(favStatusDidChange, object: _book, queue: nil) { (n: NSNotification) in
            self.syncWithBook()
        }
        _nc.addObserverForName(pdfWasFinished, object: _book, queue: nil) { (n: NSNotification) in
            self.syncWithBook()
        }
        _nc.addObserverForName(modelDidChange, object: _book, queue: nil) { (n: NSNotification) in
            self.syncWithBook()
        }
        _nc.addObserverForName(newPageOpened, object: _book, queue: nil) { (n: NSNotification) in
            self.syncWithBook()
        }
        
        syncWithBook()
        
    }
    
    func stopObserving(){
        
        if let observer = _bookObserver{
            _nc.removeObserver(observer)
            _bookObserver = nil
            _book = nil
        }
        
    }
    
    // MARK: - Utils
    
    func syncWithBook() {
        
        // Actualizo labels de titulo y autores
        self.BookTitle.text = _book?.title
        self.BookAuthors.text = _book?.authorsList()
        
        // seteo la estrella de Favorito
        if _book!.isFavorite!.boolValue {
            FavImage.image = UIImage(named: "filledStar")
        } else {
            FavImage.image = UIImage(named: "emptyStar")
        }
        
        // Seteo el page status
        //POR AHORA MUESTRO LAS PAGINAS DEL LIBRO
        if _book!.pdf.pdfData != nil {
            BookPageStatus.text = "Page \(_book!.pdf.lastPageOpen!) of \(_book!.pdf.document!.numberOfPages)"
        } else {
            BookPageStatus.text = "Not available"
        }
        
        //por ahora
        self.BookCover.image = UIImage(named: "emptyBook")
        
        guard (_book!.image.imageData != nil) else {
            print("NO hay imagen guardada en el modelo")
            self.BookCover.image = UIImage(named: "emptyBook")
            if let url = NSURL(string: _book!.image.imageURL) {
                loadImage(remoteURL: url){ (data: NSData?) in
                    
                    if let dataExist = data {
                        print("se usa imagen descargada")
                        //let image = UIImage(data: dataExist)
                        let resizeImage = UIImage(data: dataExist)!.resizedImageWithContentMode(.ScaleAspectFill, bounds: CGSize(width: 112, height: 144), interpolationQuality: .Default)
                        self.BookCover.image = resizeImage
                        //                        book.image.imageData = UIImagePNGRepresentation(UIImage(data: dataExist)!)
                        self._book!.image.imageData = UIImageJPEGRepresentation(resizeImage, 0.9)
                        // Send notification that the image finish loading
                        self._book!.imageIsLoaded = true
                    } else {
                        print("No se pudo descargar imagen, se usara la imagen por defecto")
                        self.BookCover.image = UIImage(named: "emptyBook")
                    }
                    
                }
            }
            return
        }
        
        //print(" se usa los datos de Core Data")
        self.BookCover.image = UIImage(data:_book!.image.imageData!)
        
    }
    
    //MARK: - Lifecycle
    // Sets the view in a neutral state, before being reused
    override func prepareForReuse() {
        stopObserving()
        syncWithBook()
    }
    
    deinit {
        stopObserving()
    }
}
