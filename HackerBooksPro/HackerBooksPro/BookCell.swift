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
    let _nc = NotificationCenter.default
    var _bookObserver : NSObjectProtocol?
    
    var downloadTask: URLSessionDownloadTask?
    
    // MARK: - Observing methods
    
    func startObserving(_ book: Book){
        _book = book
        // Add observers
        _nc.addObserver(forName: NSNotification.Name(rawValue: favStatusDidChange), object: _book, queue: nil) { (n: Notification) in
            self.syncWithBook()
        }
        _nc.addObserver(forName: NSNotification.Name(rawValue: pdfWasFinished), object: _book, queue: nil) { (n: Notification) in
            self.syncWithBook()
        }
        _nc.addObserver(forName: NSNotification.Name(rawValue: modelDidChange), object: _book, queue: nil) { (n: Notification) in
            self.syncWithBook()
        }
        _nc.addObserver(forName: NSNotification.Name(rawValue: newPageOpened), object: _book, queue: nil) { (n: Notification) in
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
        if _book!.pdf.pdfData != nil {
            BookPageStatus.text = "Page \(_book!.pdf.lastPageOpen!) of \(_book!.pdf.document!.numberOfPages)"
        } else {
            BookPageStatus.text = "Not available"
        }
        
        //por ahora
        self.BookCover.image = UIImage(named: "emptyBook")
        
        guard (_book!.image.imageData != nil) else {
            //print("NO hay imagen guardada en el modelo")
            self.BookCover.image = UIImage(named: "emptyBook")
            if let url = URL(string: _book!.image.imageURL) {
                loadDataAtURL(url){ (data: Data?) in
                    
                    if let dataExist = data {
                        //print("se usa imagen descargada")
                        //let image = UIImage(data: dataExist)
                        let resizeImage = UIImage(data: dataExist)!.resizedImageWithContentMode(.scaleAspectFill, bounds: CGSize(width: 112, height: 144), interpolationQuality: .default)
                        self.BookCover.image = resizeImage
                        self._book!.image.imageData = UIImageJPEGRepresentation(resizeImage, 0.9)
                        // Send notification that the image finish loading
                        self._book!.imageIsLoaded = true
                    } else {
                        //print("No se pudo descargar imagen, se usara la imagen por defecto")
                        self.BookCover.image = UIImage(named: "emptyBook")
                    }
                }
            }
            return
        }
        
        // Se usa los datos de Core Data
        self.BookCover.image = UIImage(data:_book!.image.imageData! as Data)
        
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
