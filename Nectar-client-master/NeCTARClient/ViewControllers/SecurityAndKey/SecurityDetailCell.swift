//
//  SecurityDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class SecurityDetailCell: UITableViewCell {
    

    @IBOutlet var name: UILabel!
    @IBOutlet var sDescription: UILabel!

    
    
    func setContent(index: Int) {
        let security = SecurityService.sharedService.securities[index]
        name.text = security.name

        sDescription.text = security.description
     
    }
}
