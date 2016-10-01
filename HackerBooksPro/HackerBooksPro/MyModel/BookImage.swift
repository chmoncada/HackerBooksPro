import Foundation
import UIKit

@objc(BookImage)
open class BookImage: _BookImage {
    
    var downloadTask: URLSessionDownloadTask?
    var coredataStack: CoreDataStack!
    var returnData: Data?
    
    func getImage(_ coredataStack: CoreDataStack) -> Data? {

        self.coredataStack = coredataStack
        if self.imageData != nil {
            return self.imageData as Data?
        } else {
            if let url = URL(string: self.imageURL) {
                self.downloadTask = self.loadImageWithURL(url)
            }
        }
        return nil
    }
}

extension BookImage {
    func loadImageWithURL(_ url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(
            with: url, completionHandler: { [weak self] url, response, error in
                if error == nil, let url = url,
                    
                    let returnData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.returnData = returnData
                            strongSelf.imageData = returnData
                        }
                    }
                }
            })
        
        downloadTask.resume()
        return downloadTask }
}
