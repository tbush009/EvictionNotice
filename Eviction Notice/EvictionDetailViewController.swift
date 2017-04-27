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

class EvictionDetailViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    var coreDataStack: CoreDataStack!
    var eviction: Eviction!
    var client: Client!
    var startEditing: Bool = false
    var needValue: Bool = false
    var whichButton: String!
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    //function button outlets
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var stopButton: UIButton!
    
    //date button outlets
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet var dateFiledST1: UIButton!
    @IBOutlet var dateServed: UIButton!
    @IBOutlet var dateFiledST2: UIButton!
    @IBOutlet var dateJudge: UIButton!
    
    //textfield outlets
    @IBOutlet var allTextFields: [UITextField]!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var caseNumberField: UITextField!
    @IBOutlet var whoCancelled: UITextField!
    
    //responds to date button press, checks for value and call for segue
    @IBAction func setDate(sender: AnyObject) {
        
        if sender.tag == 4 {
            whichButton = "Cancel Date"
            if eviction.cancelDate == nil {
                needValue = true
            }
        } else if sender.tag == 1 {
            whichButton = "Stage I Served Date"
            if eviction.stageOneDateServed == nil {
                needValue = true
            }

        } else if sender.tag == 2 {
            whichButton = "Stage II Filed Date"
            if eviction.stageTwoDateFiled == nil {
                needValue = true
            }
            
        } else if sender.tag == 3 {
            whichButton = "Judgement Date"
            if eviction.stageTwoDateJudgementSigned == nil {
                needValue = true
            }
            
        } else {

            whichButton = "Stage I Filed Date"
            needValue = false
        }
        
        self.performSegueWithIdentifier("ShowDatePicker", sender: self)

    }
    
    //MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDatePicker"{
            let controller = segue.destinationViewController as! DatePickerViewController
            controller.coreDataStack = self.coreDataStack
            controller.eviction = eviction
            controller.whichButton = whichButton
            controller.startEditing = needValue
        }
        if segue.identifier == "ShowImagePicker"{
            let controller = segue.destinationViewController as! ImageViewController
            controller.coreDataStack = self.coreDataStack
            controller.eviction = eviction
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateToolbarButtonWidth(view.frame.width)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        updateToolbarButtonWidth(size.width)
    }
    
    func updateToolbarButtonWidth(screenWidth: CGFloat) {
        let newWidth = (screenWidth - 50) / 2
        editButton.width = newWidth
        cancelButton.width = newWidth
    }
    
    //respond to edit/save button pressed
    @IBAction func editButtonPressed(sender: AnyObject) {
        
        startEditing = !startEditing

        if !startEditing{
            updateEviction()
            
        }
        updateUI()
        
    }
    
    //respond to cancel/delte button press
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        //if new eviction return to eviction table view
        if eviction == nil {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        if startEditing{
            startEditing = !startEditing
            updateUI()
        } else {
            let title = "Delete \(eviction.name)?"
            let message = "Are you sure you want to delete this evicion?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                
                // delete me
                self.deleteEviction()
                
            })
            ac.addAction(deleteAction)
            
            presentViewController(ac, animated: true, completion: nil)
        }
        
        
    }
    
    //deletes eviction and image
    func deleteEviction() {
        let context = coreDataStack.mainQueueContext
        let imageStore = ImageStore.sharedInstance
        
        imageStore.deleteImageForKey(eviction.fileNumber)
        context.deleteObject(eviction)
        
        do {
            try context.save()
        } catch let saveError {
            print("Error saving changes: \(saveError)")
        }
        
        // return to eviction table view
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //will update the views appearance
    func updateUI() {
        
        if startEditing {
            for textField in allTextFields {
                textField.userInteractionEnabled = true
                textField.borderStyle = .RoundedRect
            }
            editButton.title = "Save"
            cancelButton.title = "Cancel"
        } else {
            for textField in allTextFields {
                textField.userInteractionEnabled = false
                textField.borderStyle = .None
            }
            editButton.title = "Edit"
            cancelButton.title = "Delete"
        }
        
        if eviction == nil {
            navigationItem.title = "New Eviction"
            for button in allButtons{
                button.enabled = false
            }

        } else {
            navigationItem.title = eviction.name
            nameField.text = eviction.name
            addressField.text = eviction.address
            caseNumberField.text = eviction.caseNumber
            whoCancelled.text = eviction.whoCanceled
            updateButtons()

        }
    }
    
    //updates the buttons appearance and availability
    func updateButtons(){
        
        for button in allButtons{
            button.enabled = true
        }
        if let stageOneDateFiled = eviction.stageOneDateFiled {
            dateFiledST1.setTitle(dateFormatter.stringFromDate(stageOneDateFiled), forState: .Normal)
        }
        if let stageOneDateServed = eviction.stageOneDateServed {
            dateServed.setTitle(dateFormatter.stringFromDate(stageOneDateServed), forState: .Normal)
        } else {
            dateFiledST2.enabled = false
            dateJudge.enabled = false
        }
        if let stageTwoDateFiled = eviction.stageTwoDateFiled {
            dateFiledST2.setTitle(dateFormatter.stringFromDate(stageTwoDateFiled), forState: .Normal)
        } else {
            dateJudge.enabled = false
        }
        if let stageTwoDateJudged = eviction.stageTwoDateJudgementSigned {
            dateJudge.setTitle(dateFormatter.stringFromDate(stageTwoDateJudged), forState: .Normal)
            cameraButton.enabled = true
        }

        if let cancelDate = eviction.cancelDate {
            stopButton.setTitle(dateFormatter.stringFromDate(cancelDate), forState: .Normal)
            for button in allButtons{
            button.enabled = false
            }
        }
    }

    //update and store new eviction
    func updateEviction() {
        
        let context = coreDataStack.mainQueueContext
        
        if eviction == nil {
            eviction = NSEntityDescription.insertNewObjectForEntityForName("Eviction", inManagedObjectContext: context) as! Eviction
            eviction.setValue(client, forKey: "client")
        }
        eviction.setValue(nameField.text, forKey: "name")
        eviction.setValue(addressField.text, forKey: "address")
        eviction.setValue(caseNumberField.text, forKey: "caseNumber")
        eviction.setValue(whoCancelled.text, forKey: "whoCanceled")
        
        
        do {
            try context.save()
        } catch let saveError {
            print("Error saving changes to database: \(saveError)")
        }
        
    }
    
    // MARK: - TextFields
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let charSet = NSMutableCharacterSet.alphanumericCharacterSet()
        charSet.addCharactersInString(" -")
        let badChars = charSet.invertedSet
        
        if string.rangeOfCharacterFromSet(badChars) == nil {
            return true
        }
        return false
        
    }
    
}
