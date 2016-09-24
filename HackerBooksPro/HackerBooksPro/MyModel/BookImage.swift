import Foundation
import UIKit

@objc(BookImage)
public class BookImage: _BookImage {
	// Custom logic goes here.
    
    var downloadTask: NSURLSessionDownloadTask?
    var coredataStack: CoreDataStack!
    var returnData: NSData?
    
    func getImage(coredataStack: CoreDataStack) -> NSData? {

        self.coredataStack = coredataStack
        if self.imageData != nil {
            //print("HAY DATA, en el futuro se cargara del modelo de CoreData")
            return self.imageData
        } else {
            //print("Se descargara a futuro de \(self.imageURL)")
            if let url = NSURL(string: self.imageURL) {
                self.downloadTask = self.loadImageWithURL(url)
            }
        }
        return nil
    }
}

extension BookImage {
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(
            url, completionHandler: { [weak self] url, response, error in
                if error == nil, let url = url,
                    
                    returnData = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let strongSelf = self {
                            strongSelf.returnData = returnData
                            //print("ya descargado, se procedera a grabar en el modelo")
                            strongSelf.imageData = returnData
                        }
                    }
                }
            })
        
        downloadTask.resume()
        return downloadTask }
}
