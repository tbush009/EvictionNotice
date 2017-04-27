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

class ImageViewController:UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var coreDataStack: CoreDataStack!
    var eviction: Eviction!
    let imageStore = ImageStore.sharedInstance
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addButton: UIBarButtonItem!
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    //loads image if exists
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let key = eviction.fileNumber
        if let imageToDisplay = imageStore.imageForKey(key){
            imageView.image = imageToDisplay
            navigationItem.title = dateFormatter.stringFromDate(eviction.stageTwoDateJudgementSigned!)
        } else {
            navigationItem.title = "Take Picture"
        }
    }
    
    //loads camera if available
    @IBAction func takePicture(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
        }
        else {
            imagePicker.sourceType = .PhotoLibrary
        }
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //process selected image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageStore.setImage(image, forKey: eviction.fileNumber)
        
        imageView.image = image
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}
