//
//  ClientsDataSource.swift
//  Eviction Notice
//
//  Created by travis william bush on 4/7/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import UIKit

class ClientDataSource: NSObject, UITableViewDataSource {
    
    var clients: [Client] = []
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClientCell", forIndexPath: indexPath)
        
        let client = clients[indexPath.row]
        let name = client.name
        let clientNumber = client.clientNumber
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = clientNumber
        
        return cell
    }
    
}
