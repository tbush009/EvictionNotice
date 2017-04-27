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

extension Eviction {

    @NSManaged var address: String
    @NSManaged var cancelDate: NSDate?
    @NSManaged var caseNumber: String
    @NSManaged var fileNumber: String
    @NSManaged var name: String
    @NSManaged var stageOneDateFiled: NSDate?
    @NSManaged var stageOneDateServed: NSDate?
    @NSManaged var stageTwoDateFiled: NSDate?
    @NSManaged var stageTwoDateJudgementSigned: NSDate?
    @NSManaged var whoCanceled: String
    @NSManaged var client: Client?

}
