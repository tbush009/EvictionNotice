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

class ClientViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    var coreDataStack: CoreDataStack!
    var searchFilter: String = "name"
    var searchValue: String = ""  // holds string for searchbar
    
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Lifecylce functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads Dummy Data on first run
        addHundredClients()
        
    }
    
    // updates persistent settings and sets listener to do the same.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshSearchField()
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: app)
    }
    
    // remove the listener if when the view is not visible
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // updates persistent settings when the user navigates back to the app
    func applicationWillEnterForeground(notification: NSNotification) {
        refreshSearchField()
    }
    
    // function for updating search filter from settings bundle 
    // and refreshs fetch controller predicate
    func refreshSearchField(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        searchFilter = defaults.stringForKey("clientFilter")!
        searchBar.placeholder = "Search \(searchFilter)"
    }
    
    // For dummy data generation
    func addHundredClients() {
        
        let context = coreDataStack.mainQueueContext
        
        let fetchRequest = NSFetchRequest(entityName: "Client")
        var fetched: [Client]?
        do {
            fetched = try context.executeFetchRequest(fetchRequest) as? [Client]
        } catch let error {
            print("Error fetching clients: \(error)")
        }
        
        // Already has data, do nothing
        if fetched!.count > 0 {
            return
        }
        
        
        // pick a name, any name
        let names = ["Harry", "Bill", "Tom", "Dan", "Zack", "Betty", "Laura", "Emily", "Christy", "Angela"]
        let idx = arc4random_uniform(UInt32(names.count))
        let name = names[Int(idx)]
        
        
        // add a hundred peoplez
        for i in 1...100 {
            let newName = name + "\(i)"
            let newClient = NSEntityDescription.insertNewObjectForEntityForName("Client", inManagedObjectContext: context) as! Client
            newClient.setValue(newName, forKey: "name")
            newClient.setValue("123 Address St", forKey: "address")
            newClient.setValue("555-555-1234", forKey: "phone")
            newClient.setValue("555-555-4321", forKey: "fax")
            newClient.setValue("\(newName)@gmail.com", forKey: "email")
            
            // Add 300 evictions for each Client
            for j in 1...300 {
                let evicName = newName + "'s eviction \(j)"
                let newEviction = NSEntityDescription.insertNewObjectForEntityForName("Eviction", inManagedObjectContext: context)
                newEviction.setValue(evicName, forKey: "name")
                newEviction.setValue("321 Address St", forKey: "address")
                newEviction.setValue("\(i)\(i)\(j)\(j)", forKey: "caseNumber")
                newEviction.setValue(newClient, forKey: "client")
                let rand = Int(arc4random_uniform(UInt32(5)))
                switch rand {
                case 4:
                    newEviction.setValue(NSDate(), forKey: "cancelDate")
                    newEviction.setValue(newName, forKey: "whoCanceled")
                case 3:
                    newEviction.setValue(NSDate(), forKey: "stageTwoDateJudgementSigned")
                    fallthrough
                case 2:
                    newEviction.setValue(NSDate(), forKey: "stageTwoDateFiled")
                    fallthrough
                case 1:
                    newEviction.setValue(NSDate(), forKey: "stageOneDateServed")
                default:
                    break
                }
            }
        }
        
        // save me
        do {
            try context.save()
        } catch let error {
            print("Error saving data: \(error)")
        }
        
    }
    
    // MARK: - Seques
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowClientDetails" {
            // Make sure detail controller has core data stack and a client object
            if let indexPath = tableView.indexPathForSelectedRow {
                let client = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Client
                let controller = segue.destinationViewController as! ClientDetailViewController
                controller.coreDataStack = self.coreDataStack
                controller.client = client
            }
        }
        if segue.identifier == "AddNew" {
            // client detail controller automatically configures for new client if a client object is not passed in
            let controller = segue.destinationViewController as! ClientDetailViewController
            controller.coreDataStack = self.coreDataStack
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ClientCell", forIndexPath: indexPath)
        let client = fetchedResultsController.objectAtIndexPath(indexPath) as! Client
        self.configureCell(cell, withObject: client)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false // No editing for you
    }
    
    func configureCell(cell: UITableViewCell, withObject client: Client) {
        cell.textLabel?.text = client.name
        cell.detailTextLabel?.text = client.clientNumber
    }
    
    // MARK: - Search Bar Delegate and options button
    
    @IBAction func optionsButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    // shows cancel button when search bar gains first responder
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    // drops keyboard and updates search predicate just in case
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchValue = searchBar.text!
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        reloadFetchController()
    }
    
    // updates search predicate as user enters text
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchValue = searchBar.text!
        reloadFetchController()
    }
    
    // hide the cancel button if text field is empty after editing
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.showsCancelButton = false
        }
    }
    
    // clears search predicate and hides cancel button
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
        predicate = NSPredicate(format: "\(searchFilter) like %@", searchValue)
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("error performing fetch: \(error)")
        }
        tableView.reloadData()
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
        let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: context)
        fetchRequest.entity = entity
        
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
            tableView.reloadData()  // For when context is updated on other view controllers
            //self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! Client)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}