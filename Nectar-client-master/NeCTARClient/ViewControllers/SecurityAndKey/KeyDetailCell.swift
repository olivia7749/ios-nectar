//
//  KeyDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class KeyDetailCell: UITableViewCell {
    

    @IBOutlet var name: UILabel!
    @IBOutlet var fingerprint: UILabel!
    
    
    func setContent(index: Int) {
        let key = KeyService.sharedService.keys[index]
        name.text = key.name 
        fingerprint.text = key.fingerprint
        
    }
}
