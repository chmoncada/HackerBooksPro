//
//  UIImageView.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 23/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithURL(_ url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(
            with: url, completionHandler: { [weak self] url, response, error in
                if error == nil, let url = url,
                    
                    let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.image = image }
                    }
                }
            })
        
        downloadTask.resume()
        return downloadTask }
}
