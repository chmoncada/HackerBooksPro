//
//  PDFReaderViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 31/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//  Ideas from https://github.com/Dean151/PDF-reader-iOS
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageLabel: UILabel!
    
    // Allow to track if the cell is still visible of if it's been reused for async tasks
    var indexPath: IndexPath!
}
