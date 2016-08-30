//
//  BookViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 30/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

class BookViewController: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var coreDataStack: CoreDataStack?
    var model: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = model!.title
        authorsLabel.text = model!.authorsList()
        coverImage.image = UIImage(data: model!.image.imageData!)
        tagsLabel.text = model!.tagsList()
        
    }
}
