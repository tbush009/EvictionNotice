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

class ClientDetailViewController: UIViewController, UITextFieldDelegate {
    
    var coreDataStack: CoreDataStack!
    var client: Client!
    
    // Text field outlets
    @IBOutlet var numberField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var faxField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var allTextFields: [UITextField]!
    
    // Button outlets
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var statisticsButton: UIBarButtonItem!
    @IBOutlet var evictionsButton: UIBarButtonItem!
    @IBOutlet var toolbarButtons: [UIBarButtonItem]!
    
    // Toolbar Outlets
    @IBOutlet var myToolbar: UIToolbar!
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    
    // Control variables
    var editClient: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implements custom back button
        self.navigationItem.hidesBackButton = true
        let customBackButton = UIBarButtonItem(title: "くClients", style: .Plain, target: self, action: #selector(self.backButtonTapped))
        self.navigationItem.leftBarButtonItem = customBackButton
        
        // adjust bottom toolbar buttons for screen size
        updateToolbarButtonsFor(view.frame.width)
        
        // initialize UI for editing
        updateUI(false)
    }
    
    // for when the view rotates to landscape
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateToolbarButtonsFor(size.width)
    }
    
    // adjusts bottom toolbar buttons to screen size
    func updateToolbarButtonsFor(screenWidth: CGFloat) {
        let newWidth = (screenWidth - 60) / 2
        statisticsButton.width = newWidth
        evictionsButton.width = newWidth
    }
    
    func backButtonTapped(sender: AnyObject) {
        
        // destructive action, show modal alert (only shows when currently editing)
        if editClient {
            let title = "Discard Changes?"
            let message = "Are you sure you want to discard changes?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let discardAction = UIAlertAction(title: "Discard", style: .Destructive, handler: { (action) -> Void in
                if self.client == nil { // is new client, pop back to client view
                    self.navigationController?.popViewControllerAnimated(true)
                } else { // existing client, refresh view without saving data
                    self.editClient = !self.editClient
                    self.updateUI(true)
                }
            })
            ac.addAction(discardAction)
            
            presentViewController(ac, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
        // final data validation should take place here
        if editClient {
            if let clientName = nameField.text where clientName == "" {
                let ac = UIAlertController(title: "Invalid Name!",
                                           message: "Client name field cannot be empty.",
                                           preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                ac.addAction(okAction)
                presentViewController(ac, animated: true, completion: nil)
                return
            }
        }
        
        editClient = !editClient
        
        // update coreDataStack only when "Done" Button is pressed
        if !editClient {
            updateCoreDataStack()
        }
        
        // finally update the view
        updateUI(true)
    }
    
    // creates an alert to confirm if the user really wants to delete
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        
        let title = "Delete \(client.name)?"
        let message = "Are you sure you want to delete this client?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            
            // delete me
            self.deleteClient()
            
        })
        ac.addAction(deleteAction)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // Function for refreshing view layer
    func updateUI(animated: Bool) {
        
        // sets up view for new or existing client
        if client == nil {
            navigationItem.title = "New Client"
            editClient = true
        } else {
            navigationItem.title = "\(client.name)"
            numberField.text = client.clientNumber
            nameField.text = client.name
            addressField.text = client.address
            phoneField.text = client.phone
            faxField.text = client.fax
            emailField.text = client.email
        }
        
        // switches view between editing and viewing modes
        if editClient {
            for textField in allTextFields {
                textField.userInteractionEnabled = true
                textField.borderStyle = .RoundedRect
            }
            editButton.title = "Save"
            navigationItem.leftBarButtonItem?.title = "Cancel"
            toolbarBottomConstraint.constant = -myToolbar.frame.height // hide toolbar
        } else {
            for textField in allTextFields {
                textField.userInteractionEnabled = false
                textField.borderStyle = .None
            }
            editButton.title = "Edit"
            navigationItem.leftBarButtonItem?.title = "くClients"
            toolbarBottomConstraint.constant = 0 // show toolbar
        }
        
        
        if animated { // animates everything
            UIView.animateWithDuration(0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func updateCoreDataStack() {
        let context = coreDataStack.mainQueueContext
        
        if client == nil {
            client = NSEntityDescription.insertNewObjectForEntityForName("Client", inManagedObjectContext: context) as! Client
        }
        if let clientNumber = numberField.text where clientNumber != "" {
            client.setValue(clientNumber, forKey: "clientNumber")
        }
        client.setValue(nameField.text, forKey: "name")
        client.setValue(addressField.text, forKey: "address")
        client.setValue(phoneField.text, forKey: "phone")
        client.setValue(faxField.text, forKey: "fax")
        client.setValue(emailField.text, forKey: "email")
        
        do {
            try context.save()
        } catch let saveError {
            print("Error saving changes to database: \(saveError)")
        }
    }
    
    func deleteClient() {
        let context = coreDataStack.mainQueueContext
        let imageStore = ImageStore.sharedInstance
        
        // Delete all evictions for client
        for eviction in client.evictions {
            imageStore.deleteImageForKey(eviction.fileNumber)
            context.deleteObject(eviction)
        }
        
        // Delete Client
        context.deleteObject(client)
        
        do {
            try context.save()
        } catch let saveError {
            print("Error saving changes: \(saveError)")
        }
        
        // return to clients table view
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowClientStatistics" {
            let controller = segue.destinationViewController as! ClientStatisticsViewController
            let statsBox = StatsBox(forClient: client)
            controller.statsBox = statsBox
            controller.client = client
        }
        if segue.identifier == "ShowEvictions" {
            let controller = segue.destinationViewController as! EvictionViewController
            controller.coreDataStack = self.coreDataStack
            controller.client = client
        }
    }
    
    // MARK: - TextFields
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // validation goes here
        
        // default for name and address field
        var charSet = NSMutableCharacterSet.alphanumericCharacterSet()
        charSet.addCharactersInString(" -")
        
        if textField.tag == 1 { // Phone number Fields
            charSet = NSMutableCharacterSet(charactersInString: "()-1234567890")
        } else if textField.tag == 2 { // Email Fields
            charSet.addCharactersInString("-_@.")
        }
        
        let badCharacters = charSet.invertedSet
        
        if string.rangeOfCharacterFromSet(badCharacters) == nil {
            return true
        }
        
        return false
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}