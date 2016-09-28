//
//  DownloadPDF.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 30/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import Foundation

class Download: NSObject {
    var url: String
    //var title: String
    //var isDownloading = false - Future implementation
    var progress: Float = 0.0
    
    var downloadTask: URLSessionDownloadTask?
    //var resumeData: NSData? - Future implementation
    
    init(url: String) {
        self.url = url
        //self.title = title
    }
    
}
