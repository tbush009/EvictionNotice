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

extension Client {

    @NSManaged var address: String
    @NSManaged var clientNumber: String
    @NSManaged var email: String
    @NSManaged var fax: String
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var evictions: Set<Eviction>

}
