//
//  Load-Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Load Utils

/**
 
 Return data from a URLSessionDataTask to a completion handler
 
 - parameters:
    -   url: the URL of the data
 
 */
func loadDataAtURL(_ url: URL, completion: @escaping (_ data: Data?) -> ())  {
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if (error != nil) {
            DispatchQueue.main.async(execute: {() in
                completion(nil)
            })
            return
        }
        if let data = data {
            DispatchQueue.main.async(execute: {() in
                completion(data)
            })
            return
        }
        
    })
    
    downloadTask.resume()
    
}







