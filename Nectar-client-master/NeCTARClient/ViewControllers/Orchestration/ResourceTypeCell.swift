//
//  File.swift
//  NeCTARClient
//
//  Created by Qi Qi on 1/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class ResourceTypeCell: UITableViewCell {
    
    @IBOutlet var typeName: UILabel!
    
    // Set the content of a cell according to the associated resource type's index
    func setContent(index: Int) {
        let type = ResourceTypeService.sharedService.types[index]
        typeName.text = type.type

    }
}
