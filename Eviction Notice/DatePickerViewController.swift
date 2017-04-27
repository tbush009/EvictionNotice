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

class DatePickerViewController: UIViewController {
    var coreDataStack: CoreDataStack!
    var eviction: Eviction!
    var whichButton: String!
    var startEditing: Bool = false


    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var datePicker: UIDatePicker!
    
    //sets date picker and UI on load
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.datePickerMode = .Date
        updateUI()
    }
    
    //resonds to edit/save button press
    @IBAction func editButtonPressed(sender: AnyObject) {
        startEditing = !startEditing
        
        if !startEditing{
            updateEviction()
            
        }
        updateUI()
    }
    
    //updates the UI
    func updateUI() {

        
        if startEditing {
            editButton.title = "Save"
            datePicker.userInteractionEnabled = true
            navigationItem.title = "Pick \(whichButton)"
        } else {
            editButton.title = "Edit"
            datePicker.userInteractionEnabled = false
            navigationItem.title = whichButton
            setDate()
        }
    }
    
    //sets date from appropriate button
    func setDate() {
        switch (whichButton) {
        case "Cancel Date":
            datePicker.date = eviction.cancelDate!
        case "Stage I Served Date":
            datePicker.date = eviction.stageOneDateServed!
        case "Stage II Filed Date":
            datePicker.date = eviction.stageTwoDateFiled!
        case "Judgement Date":
            datePicker.date = eviction.stageTwoDateJudgementSigned!
        default:
            datePicker.date = eviction.stageOneDateFiled!
        }
    }
    
    //updates date for appropriate button
    func updateEviction() {
        
        let context = coreDataStack.mainQueueContext
        
        switch (whichButton) {
        case "Cancel Date":
            eviction.cancelDate = datePicker.date
        case "Stage I Served Date":
            eviction.stageOneDateServed = datePicker.date
        case "Stage II Filed Date":
            eviction.stageTwoDateFiled = datePicker.date
        case "Judgement Date":
            eviction.stageTwoDateJudgementSigned = datePicker.date
        default:
            eviction.stageOneDateFiled = datePicker.date
        }
        
        do {
            try context.save()
            navigationController?.popViewControllerAnimated(true)
        } catch let saveError {
            print("Error saving changes to database: \(saveError)")
        }
        
    }

}
