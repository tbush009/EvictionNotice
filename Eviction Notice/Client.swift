//
//  PROGRAMMERS: Jorge Guevara, Travis Bush
//  PANTHERID:   3809308, 2485903
//  CLASS:       COP 465501 TR 5:00
//  INSTRUCTOR:  Steve Luis ECS 282
//  ASSIGNMENT:  Final Project
//  DUE:         Thursday 04/27/17
//

import Foundation
import CoreData


class Client: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        clientNumber = NSUUID().UUIDString
        name = ""
        address = ""
        email = ""
        phone = ""
        fax = ""
        evictions = []
    }

}
