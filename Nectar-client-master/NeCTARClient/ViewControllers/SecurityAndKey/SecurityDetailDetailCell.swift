//
//  SecurityDetailDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class SecurityDetailDetailCell: UITableViewCell {
    
    
    @IBOutlet var direction: UILabel!
    @IBOutlet var etherType: UILabel!
    @IBOutlet var ipProtool: UILabel!
    @IBOutlet var range: UILabel!
    @IBOutlet var remotePrefix: UILabel!
    @IBOutlet var remoteName: UILabel!
    
    
    func setContent(security: Security, index: Int) {
        direction.text = security.direction[index].capitalizedString
        etherType.text = security.ethertype[index]
        ipProtool.text = security.ipProtocol[index]
        range.text = security.portRange[index]
        remotePrefix.text = security.remoteIpPrefix[index]
        remoteName.text = security.remoteGroupName[index]  
    }
}
