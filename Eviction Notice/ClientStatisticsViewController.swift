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

class ClientStatisticsViewController: UIViewController {
    
    var statsBox: StatsBox! // A wonderful class for generating stats
    var client: Client!
    
    // Label Outlets
    @IBOutlet var clientNameLabel: UILabel!
    @IBOutlet var allCountLabel: UILabel!
    @IBOutlet var openCountLabel: UILabel!
    @IBOutlet var completeCountLabel: UILabel!
    @IBOutlet var cancelCountLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // tell stats box to calculate stats
        statsBox.getStatsForClient()
        
        // update view from stats box's memeber variables
        clientNameLabel.text = "Statistics for Client: \(client.name)"
        allCountLabel.text = "\(statsBox.allCount)"
        openCountLabel.text = "\(statsBox.openCount)"
        completeCountLabel.text = "\(statsBox.completeCount)"
        cancelCountLabel.text = "\(statsBox.cancelCount)"

    }
    
}

