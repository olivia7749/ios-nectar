//
//  FloatingIPDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 19/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class FloatingIPDetailCell: UITableViewCell {
    @IBOutlet var ipAddress: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var pool: UILabel!
    @IBOutlet var status: UILabel!
    
    // Set the content of a cell according to the associated floating IP's index
    func setContent(index: Int) {
        let floatingIP = FloatingIPsService.sharedService.floatingIPs[index]
        ipAddress.text = floatingIP.ipAddress
        descrip.text = floatingIP.descrip
        pool.text = floatingIP.pool
        status.text = floatingIP.status
    }
    
}
