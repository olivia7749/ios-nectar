//
//  DatabaseInstanceDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class DatabaseInstanceDetailCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var datastore: UILabel!
    @IBOutlet var datastoreVersion: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var viewBackups: UIButton!
    
    // Set the content of a cell according to the associated database instance's index
    func setContent(index: Int) {
        let instance = DatabaseInstanceService.sharedService.databaseInstances[index]
        name.text = instance.name
        id.text = instance.id
        datastore.text = instance.datastore
        datastoreVersion.text = instance.datastoreVersion
        status.text = instance.status
    }
    
}