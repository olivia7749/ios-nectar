//
//  ObjectDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class ObjectDetailCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var contentType: UILabel!
    @IBOutlet var bytes: UILabel!
    @IBOutlet var lastModified: UILabel!
    @IBOutlet var hashList: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    // Set the content of a cell according to the associated object's index
    func setContent(index: Int) {
        let object = ObjectService.sharedService.objects[index]
        contentType.text = object.contentType
        bytes.text = object.bytes
        name.text = object.name
        lastModified.text = object.lastModified
        hashList.text = object.hashList
        
    }
    
    
}
