//
//  StackDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class StackDetailCell: UITableViewCell {
    
    @IBOutlet var stackName: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var updated: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var status: UILabel!
    
    // Set the content of a cell according to the associated resource type's index
    func setContent(index: Int) {
        let stack = StackService.sharedService.stacks[index]
        stackName.text = stack.name
        created.text = stack.created
        updated.text = stack.updated
        descrip.text = stack.descrip
        status.text = stack.status
    }
}
