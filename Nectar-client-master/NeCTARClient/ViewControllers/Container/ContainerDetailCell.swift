//
//  ContainerDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class ContainerDetailCell: UITableViewCell {
    
    @IBOutlet var count: UILabel!
    @IBOutlet var bytes: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Set the content of a cell according to the associated container's index
    func setContent(index: Int) {
        let container = ContainerService.sharedService.containers[index]
        count.text = container.count
        bytes.text = container.bytes
        name.text = container.name
        
    }
    
    
}

