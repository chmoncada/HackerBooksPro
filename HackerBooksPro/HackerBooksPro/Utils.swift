//
//  Utils.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation
import UIKit

//// Sandbox utils YA NO SIRVE???
//func saveData(data: NSData, name: String){
//    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//    let writePath = NSURL(fileURLWithPath: documents).URLByAppendingPathComponent(name)
//    data.writeToURL(writePath, atomically: false)
//    
//    
//}

//func loadImage(remoteURL url: NSURL, completion: (image: UIImage?, data: NSData?) -> ())  {
//    
//    var imageView : UIImage?
//    
//    
//    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//        if (error != nil) {
//            dispatch_async(dispatch_get_main_queue(), {() in
//                completion(image: nil, data:  nil)
//            })
//            return
//        }
//        if let data = data {
//            imageView = UIImage(data: data)
//            dispatch_async(dispatch_get_main_queue(), {() in
//                completion(image: imageView, data:  data)
//            })
//            return
//        }
//        
//    })
//    
//    downloadTask.resume()
//    
//}


func loadImage(remoteURL url: NSURL, completion: (data: NSData?) -> ())  {
    
    //var imageView : UIImage?
    
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), {() in
                completion(data:  nil)
            })
            return
        }
        if let data = data {
            //imageView = UIImage(data: data)
            dispatch_async(dispatch_get_main_queue(), {() in
                completion(data:  data)
            })
            return
        }
        
    })
    
    downloadTask.resume()
    
}