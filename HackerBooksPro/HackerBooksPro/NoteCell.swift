//
//  NoteCell.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 17/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Allow to track if the cell is still visible of if it's been reused for async tasks
    //var indexPath: NSIndexPath!
}
