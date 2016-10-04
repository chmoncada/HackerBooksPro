//
//  LibraryViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 12/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices



//MARK: - Protocol BookSelectionDelegate

// Protocol definition to inject the selected book to the delegate
protocol BookSelectionDelegate: class {
    func bookSelected(_ newBook: Book)
}

class LibraryViewController: UIViewController {

    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    weak var delegate: BookSelectionDelegate?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var tableToShow: tableType?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - IBAction
    
    /// Change the `tableType` from the selection of the segmented control
    @IBAction func tableTypeChanged(_ sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableToShow = tableType.title
            let frc = getFetchedResultsController(tableToShow!)
            setNewFetchedResultsController(frc)
        case 1:
            tableToShow = tableType.tag
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
        searchBar.barTintColor = UIColor.black
        searchBar.searchBarStyle = .default
        // Setup of initial tableType
        segmentedControl.selectedSegmentIndex = 0
        tableToShow = tableType.title
        
        setupSearchableContent()
        
        fetchedResultsController = getFetchedResultsController(tableToShow!)
        fetch()
        fetchedResultsController.delegate = self
        
    }

}


// MARK: - UITableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        var book: Book?
        
        switch tableToShow! {
        case tableType.title:
            book = fetchedResultsController.object(at: indexPath) as? Book
        case tableType.tag:
            let bookTag = fetchedResultsController.object(at: indexPath) as? BookTag
            book = bookTag!.book
        case tableType.searchResults:
            book = fetchedResultsController.object(at: indexPath) as? Book
        }
        
        cell.startObserving(book!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if sectionInfo.name == "___favorite" {
            return "FAVORITE"
        } else if sectionInfo.name == "__recent" {
            return "RECENT (7 days)"
        } else if sectionInfo.name == "_finished" {
            return "FINISHED"
        } else {
            return sectionInfo.name.uppercased()
        }

    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let title = UILabel()
        title.textColor = UIColor(red: 1.0, green: 0.737, blue: 0.173, alpha: 1.00)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = title.textColor
        
    }
    
}


// MARK: - UITableViewDelegate
extension LibraryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedBook: Book
        if tableToShow == tableType.tag {
            let selectedBookTag = fetchedResultsController.object(at: indexPath) as! BookTag
            selectedBook = selectedBookTag.book
        } else {
            selectedBook = fetchedResultsController.object(at: indexPath) as! Book
        }
        
        self.delegate?.bookSelected(selectedBook)
        let notif = Notification(name: Notification.Name(rawValue: selectAnotherBook), object: nil)
        NotificationCenter.default.post(notif)
        
        if let detailViewController = self.delegate as? BookViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
}

// MARK: - NSFetchedResultsController methods
extension LibraryViewController {
   
    /**
     **Returns** an `NSFetchedResultsController` depends of tableType value.
     - parameters:
        - type: tableType value.
        - predicate: optional predicate.
     */
    func getFetchedResultsController(_ type: tableType, predicate: NSPredicate = NSPredicate()) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        switch type {
            
        case tableType.title:

            let fetchRequest = NSFetchRequest<Book>(entityName: Book.entityName())
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            // Reset searchBar text
            searchBar.text = ""
            searchBar.resignFirstResponder()
            
            let fReq: NSFetchedResultsController<Book> = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
            return fReq as! NSFetchedResultsController<NSFetchRequestResult>
        case tableType.tag:
            
            let fetchRequest = NSFetchRequest<BookTag>(entityName: BookTag.entityName())
            let sortDescriptor1 = NSSortDescriptor(key: "tag.proxyForSorting", ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: "book.title", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor1,sortDescriptor2]
            fetchRequest.fetchBatchSize = 20
            
            // Reset searchBar text
            searchBar.text = ""
            searchBar.resignFirstResponder()
            
            let fReq = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: "tag.proxyForSorting",
                                              cacheName: nil)
            return fReq as! NSFetchedResultsController<NSFetchRequestResult>
        case tableType.searchResults:
            
            let fetchRequest = NSFetchRequest<Book>(entityName: Book.entityName())
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "\(BookAttributes.title)", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            let fReq = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreDataStack.context,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
            return fReq as! NSFetchedResultsController<NSFetchRequestResult>
        
        }
        
    }
    
    /**
     Set a **new** `NSFetchedResultsController` for the tableview.
     - parameters:
        - newfrc: the new `NSFetchedResultsController`.
     */
    func setNewFetchedResultsController(_ newfrc: NSFetchedResultsController<NSFetchRequestResult>) {
        
        let oldfrc = fetchedResultsController
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            newfrc.delegate = self
            fetch()
            tableView.reloadData()
        }
        
    }
    
    /// a convenience method to wrap the error handling of the perforFetch of the NSFetchedResultsController
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?,
                                for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //print("Se detecto cambios")
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default :
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}


//MARK: - UISearchBarDelegate
extension LibraryViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // Obtain the text of the search bar
        let searchString = searchBar.text!
        
        // Make a predicate fot the fetch
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", "title", searchString, "bookTags.tag.tag", searchString, "authors.name", searchString) 
        
        // Change the type of table and set the new fetchResultsController and show the results in the tableview 
        tableToShow = tableType.searchResults
        let frc = getFetchedResultsController(tableToShow!, predicate: predicate)
        setNewFetchedResultsController(frc)
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

// MARK: Core Spotlight

extension LibraryViewController {
    
    func setupSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        
        let fetchRequestForSpotlight = NSFetchRequest<Book>(entityName: Book.entityName())
        
        do {
            let results = try coreDataStack.context.fetch(fetchRequestForSpotlight)
            
            for each in results {
                
                var keywords = [String]()
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                searchableItemAttributeSet.title = each.title
                //keywords.append(each.title)
                
                searchableItemAttributeSet.thumbnailData = each.image.imageData
                
                var authorArray = [String]()
                for author in each.authors {
                    authorArray.append((author as! Author).name)
                    //keywords.append((author as! Author).name)
                }
                searchableItemAttributeSet.authorNames = authorArray
                
                if let pdfText = each.pdf.text {
                    print("encontre texto en \(each.title) \(pdfText)")
                    searchableItemAttributeSet.contentDescription = pdfText
                }
                
                searchableItemAttributeSet.keywords = keywords
                
                
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: "com.charlesmoncada.HackerBooksPro.\(each.title)", domainIdentifier: "books", attributeSet: searchableItemAttributeSet)
                
                searchableItems.append(searchableItem)
                
            }
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) -> Void in
                
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
            
        } catch {
            print("ERROR")
        }
    }
    
    
    
}
