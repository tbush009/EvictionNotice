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

// A magic box that generates client stats
class StatsBox {
    
    var client: Client
    
    // member variables for stats
    var allCount: Int = 0
    var openCount: Int = 0
    var completeCount: Int = 0
    var cancelCount: Int = 0
    
    // constructor, requires a client object
    init(forClient client: Client) {
        self.client = client
    }
    
    // calculates client statistics
    func getStatsForClient() {
        
        for eviction in client.evictions {
            allCount += 1
            if eviction.cancelDate != nil {
                cancelCount += 1
            } else if eviction.stageTwoDateJudgementSigned != nil {
                completeCount += 1
            } else {
                openCount += 1
            }
        }
    }
    
}
