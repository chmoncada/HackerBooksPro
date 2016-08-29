//
//  ViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

class LibraryViewController: UIViewController {

    var coreDataStack: CoreDataStack!
    
    //POR AHORA IMPLEMENTAREMOS EL FETCHEDRESULTS ACA
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //To show first row in the table due to searchBar
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        searchBar.barTintColor = UIColor.blackColor()
        searchBar.searchBarStyle = .Default
        
        //POR AHORA IMPLEMENTRAMOS EL FETCH RESULTS ACA
        let fetchRequest = NSFetchRequest(entityName: "\(Book.entityName())")
        
        let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        fetchedResultsController.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Utils
    
//    func configureCell(cell: BookCell, indexPath: NSIndexPath) {
//        
//        let book = fetchedResultsController.objectAtIndexPath(indexPath) as! Book
//        
//        cell.BookCover.image = UIImage(named: "emptyBook")
//        cell.BookTitle.text = book.title
//        cell.BookAuthors.text = "AUTORES"
//    }

}


// MARK: - UITableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookCell
        
        //let book = fetchedResultsController.objectAtIndexPath(indexPath) as! Book
        
        cell.configureCell(fetchedResultsController, indexPath: indexPath, coreDataStack: coreDataStack)
        
        return cell
        
    }
    
}


// MARK: - UITableViewDelegate
extension LibraryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}

//MARK: - NSFetchedResultControllerDelegate

extension LibraryViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                                forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("Se detecto cambios")
        switch type {
        case .Insert: tableView.insertRowsAtIndexPaths([newIndexPath!],
                                                       withRowAnimation: .Automatic)
        case .Delete: tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update: let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BookCell
            cell.configureCell(fetchedResultsController, indexPath: indexPath!, coreDataStack: coreDataStack)
        case .Move: tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic) }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

//MARK: - UISearchBarDelegate

extension LibraryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        print("The search text is: '\(searchBar.text!)'")
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

