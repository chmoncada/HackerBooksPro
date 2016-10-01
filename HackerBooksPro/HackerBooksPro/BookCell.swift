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
        
        // AUpdate labels
        self.BookTitle.text = _book?.title
        self.BookAuthors.text = _book?.authorsList()
        
        // Favorite star setting
        if _book!.isFavorite!.boolValue {
            FavImage.image = UIImage(named: "filledStar")
        } else {
            FavImage.image = UIImage(named: "emptyStar")
        }
        
        // Update page status
        if _book!.pdf.pdfData != nil {
            BookPageStatus.text = "Page \(_book!.pdf.lastPageOpen!) of \(_book!.pdf.document!.numberOfPages)"
        } else {
            BookPageStatus.text = "Not available"
        }
        
        self.BookCover.image = UIImage(named: "emptyBook")
        
        guard (_book!.image.imageData != nil) else {
            
            self.BookCover.image = UIImage(named: "emptyBook")
            if let url = URL(string: _book!.image.imageURL) {
                loadDataAtURL(url){ (data: Data?) in
                    
                    if let dataExist = data {
                        
                        let resizeImage = UIImage(data: dataExist)!.resizedImageWithContentMode(.scaleAspectFill, bounds: CGSize(width: 112, height: 144), interpolationQuality: .default)
                        self.BookCover.image = resizeImage
                        self._book!.image.imageData = UIImageJPEGRepresentation(resizeImage, 0.9)
                        // Send notification that the image finish loading
                        self._book!.imageIsLoaded = true
                    } else {
                        self.BookCover.image = UIImage(named: "emptyBook")
                    }
                }
            }
            return
        }
        
        // Use model data
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
