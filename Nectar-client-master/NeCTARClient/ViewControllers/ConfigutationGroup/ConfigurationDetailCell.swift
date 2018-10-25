//
//  ConfigurationDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 29/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class ConfigurationDetailCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var datastore: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var updated: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Set the content of a cell according to the associated configuration's index
    func setContent(index: Int) {
        let group = ConfigurationGroupService.sharedService.configutationGroups[index]
        name.text = group.name
        descrip.text = group.descrip
        id.text = group.id
        datastore.text = group.datastore
        created.text = group.created
        updated.text = group.updated
    }  
}
