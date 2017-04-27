//
//  PROGRAMMERS: Jorge Guevara, Travis Bush
//  PANTHERID:   3809308, 2485903
//  CLASS:       COP 465501 TR 5:00
//  INSTRUCTOR:  Steve Luis ECS 282
//  ASSIGNMENT:  Final Project
//  DUE:         Thursday 04/27/17
//

import UIKit
import CoreData

class EvictionViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    var coreDataStack: CoreDataStack!
    var client: Client!
    var searchFilter = "name"
    
    //searchBar value temporary storage
    var searchValue = ""
    
    //searchBar outlet
    @IBOutlet var searchBar: UISearchBar!
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    //checking default setting and refreshing searchbar
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshSearchField()
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: app)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //refreshing searchBar when app enters forground
    func applicationWillEnterForeground(notification: NSNotification) {
        refreshSearchField()
    }
    
    //checks defaults chosen and sets the search filter
    func refreshSearchField(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        searchFilter = defaults.stringForKey("evictionFilter")!
        searchBar.placeholder = "Search \(searchFilter)"
    }
    
    //cancel button appears when user selects searchBar
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    //stores search value and call update for fetch controller when search is pressed
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchValue = searchBar.text!
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        reloadFetchController()
    }
    
    //stores search value and call update for fetch controller when text is entered
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchValue = searchBar.text!
        reloadFetchController()
        
    }
    
    //stores search value and call update for fetch controller
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchValue = searchBar.text!
        searchBar.resignFirstResponder()
        reloadFetchController()
    }
    
    //clears searchbar, hides cancel button, closes keyboard and call update for fetch controller
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchValue = ""
        searchBar.text = ""
        searchBar.showsCancelButton = false
        reloadFetchController()
        searchBar.resignFirstResponder()
    }
    
    // Reloads the fetched results controller with a predicate from the search bar.
    func reloadFetchController() {
        var predicate = NSPredicate()
        searchValue = "*\(searchValue)*"
        predicate = NSPredicate(format: "\(searchFilter) like %@ AND client ==%@", searchValue, client )
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("error performing fetch: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Seques
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEvictionDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let eviction = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Eviction
                let controller = segue.destinationViewController as! EvictionDetailViewController
                controller.coreDataStack = self.coreDataStack
                controller.eviction = eviction
            }
        }
        if segue.identifier == "AddNew" {
            let controller = segue.destinationViewController as! EvictionDetailViewController
            controller.coreDataStack = self.coreDataStack
            controller.client = client
            controller.startEditing = true
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EvictionCell", forIndexPath: indexPath) as! EvictionCell
        let eviction = fetchedResultsController.objectAtIndexPath(indexPath) as! Eviction
        self.configureCell(cell, withObject: eviction)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func configureCell(cell: EvictionCell, withObject eviction: Eviction) {
        cell.nameLabel.text = eviction.name
        cell.caseNumberLabel.text = eviction.caseNumber
        if eviction.cancelDate != nil {
            cell.statusLabel.text = "Cancelled"
        } else if eviction.stageTwoDateJudgementSigned != nil {
            cell.statusLabel.text = "Completed"
        } else {
            cell.statusLabel.text = "Open"
        }
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Switch to private queue context if necessary
        let context = coreDataStack.mainQueueContext
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Eviction", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "client == %@", client)
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let fetchError {
            print("Error fetching client data: \(fetchError)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadData()  // prevents invalid index error
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    
    
}
