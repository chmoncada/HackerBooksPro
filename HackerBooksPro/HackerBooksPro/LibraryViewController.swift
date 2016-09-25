//
//  LibraryViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData

// Protocol definition to inject the selected book to the delegate

//MARK: - Protocol BookSelectionDelegate

protocol BookSelectionDelegate: class {
    func bookSelected(newBook: Book)
}

//MARK: - Enum para el tipo de tabla
enum tableType {
    case Title
    case Tag
    case SearchResults
}

class LibraryViewController: UIViewController {

    // MARK: - Properties
    
    var coreDataStack: CoreDataStack!
    
    weak var delegate: BookSelectionDelegate?
    
    var fetchedResultsController: NSFetchedResultsController!
    
    var tableToShow: tableType?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - IBAction
    
    @IBAction func tableTypeChanged(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableToShow = tableType.Title
            let frc = getFetchedResultsController(tableToShow!)
            setNewFetchedResultsController(frc)
        case 1:
            tableToShow = tableType.Tag
            let frc = getFetchedResultsController(tableToShow!)
            setNewFetchedResultsController(frc)
        default:
            break
        }
        
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //To show first row in the table due to searchBar
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        searchBar.barTintColor = UIColor.blackColor()
        searchBar.searchBarStyle = .Default
        //Seteo la tabla inicial
        segmentedControl.selectedSegmentIndex = 0
        tableToShow = tableType.Title
        
        fetchedResultsController = getFetchedResultsController(tableToShow!)
        fetch()
        fetchedResultsController.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("*** deinit \(self)")
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Utils
    
    func favChange(notification: NSNotification) {
        self.tableView.reloadData()
    }

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
        
        var book: Book?
        
        switch tableToShow! {
        case tableType.Title:
            //print("soy tipo titulo")
            book = fetchedResultsController.objectAtIndexPath(indexPath) as? Book
        case tableType.Tag:
            //print("soy tipo tag")
            let bookTag = fetchedResultsController.objectAtIndexPath(indexPath) as? BookTag
            book = bookTag!.book
        case tableType.SearchResults:
            //print("soy tipo search")
            book = fetchedResultsController.objectAtIndexPath(indexPath) as? Book
        }
        
        cell.startObserving(book!)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if sectionInfo.name == "___favorite" {
            return "FAVORITE"
        } else if sectionInfo.name == "__recent" {
            return "RECENT (7 days)"
        } else if sectionInfo.name == "_finished" {
            return "FINISHED"
        } else {
            return sectionInfo.name.uppercaseString
        }

    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = title.textColor
        
    }
    
}


// MARK: - UITableViewDelegate
extension LibraryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedBook: Book
        if tableToShow == tableType.Tag {
            let selectedBookTag = fetchedResultsController.objectAtIndexPath(indexPath) as! BookTag
            selectedBook = selectedBookTag.book
        } else {
            selectedBook = fetchedResultsController.objectAtIndexPath(indexPath) as! Book
        }
        
        self.delegate?.bookSelected(selectedBook)
        
        if let detailViewController = self.delegate as? BookViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
        
    }
    
    
}

// MARK: - NSFetchedResultsController methods

extension LibraryViewController {
    
    func getFetchedResultsController(type: tableType, predicate: NSPredicate = NSPredicate()) -> NSFetchedResultsController {
        
        var fReq: NSFetchedResultsController?
        
        switch type {
            
        case tableType.Title:
            let fetchRequest = NSFetchRequest(entityName: Book.entityName())
            
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            fReq = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        case tableType.Tag:
            let fetchRequest = NSFetchRequest(entityName: BookTag.entityName())
            
            let sortDescriptor1 = NSSortDescriptor(key: "tag.proxyForSorting", ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: "book.title", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor1,sortDescriptor2]
            fetchRequest.fetchBatchSize = 20
            
            fReq = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: "tag.proxyForSorting",
                                              cacheName: nil)
        case tableType.SearchResults:
            let fetchRequest = NSFetchRequest(entityName: Book.entityName())
            
            fetchRequest.predicate = predicate
            
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            fReq = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        
        }
        
        return fReq!
    }
    
    
    func setNewFetchedResultsController(newfrc: NSFetchedResultsController) {
        
        let oldfrc = fetchedResultsController
        
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            newfrc.delegate = self
            fetch()
            tableView.reloadData()
            
        }
        
    }
    
    
    func fetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
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
        //print("Se detecto cambios")
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default :
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}


//MARK: - UISearchBarDelegate

extension LibraryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        //print("The search text is: '\(searchBar.text!)'")
        let searchString = searchBar.text!
        
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", "title", searchString, "bookTags.tag.tag", searchString, "authors.name", searchString) 
        
        tableToShow = tableType.SearchResults
        let frc = getFetchedResultsController(tableToShow!, predicate: predicate)
        setNewFetchedResultsController(frc)
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

